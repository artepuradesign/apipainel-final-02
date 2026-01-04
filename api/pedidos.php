<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'conexao.php';

/**
 * API de Pedidos
 * 
 * GET /api/pedidos.php?email=xxx - Buscar pedidos por email do cliente
 * GET /api/pedidos.php?numero=xxx - Buscar pedido por número
 * POST /api/pedidos.php - Criar novo pedido
 */

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            handleGet($pdo);
            break;
        case 'POST':
            handlePost($pdo);
            break;
        default:
            http_response_code(405);
            echo json_encode(['success' => false, 'error' => 'Método não permitido']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}

function handleGet($pdo) {
    // Buscar por email
    if (isset($_GET['email'])) {
        $email = trim($_GET['email']);
        
        $stmt = $pdo->prepare("
            SELECT 
                p.*,
                (SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id', pi.id,
                        'produto_id', pi.produto_id,
                        'nome', pi.produto_nome,
                        'sku', pi.produto_sku,
                        'imagem', pi.produto_imagem,
                        'quantidade', pi.quantidade,
                        'preco_unitario', pi.preco_unitario,
                        'subtotal', pi.subtotal
                    )
                ) FROM pedido_itens pi WHERE pi.pedido_id = p.id) as itens
            FROM pedidos p
            WHERE p.email_cliente = ?
            ORDER BY p.created_at DESC
        ");
        $stmt->execute([$email]);
        $pedidos = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Processar itens JSON
        foreach ($pedidos as &$pedido) {
            $pedido['itens'] = $pedido['itens'] ? json_decode($pedido['itens'], true) : [];
        }
        
        echo json_encode(['success' => true, 'data' => $pedidos]);
        return;
    }
    
    // Buscar por número do pedido
    if (isset($_GET['numero'])) {
        $numero = trim($_GET['numero']);
        
        $stmt = $pdo->prepare("
            SELECT p.* FROM pedidos p WHERE p.numero = ?
        ");
        $stmt->execute([$numero]);
        $pedido = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$pedido) {
            http_response_code(404);
            echo json_encode(['success' => false, 'error' => 'Pedido não encontrado']);
            return;
        }
        
        // Buscar itens do pedido
        $stmtItens = $pdo->prepare("
            SELECT 
                id,
                produto_id,
                produto_nome as nome,
                produto_sku as sku,
                produto_imagem as imagem,
                quantidade,
                preco_unitario,
                subtotal
            FROM pedido_itens 
            WHERE pedido_id = ?
        ");
        $stmtItens->execute([$pedido['id']]);
        $pedido['itens'] = $stmtItens->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $pedido]);
        return;
    }
    
    // Sem filtro - retorna erro
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Parâmetro email ou numero é obrigatório']);
}

function handlePost($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Dados inválidos']);
        return;
    }
    
    // Validar campos obrigatórios
    $required = ['nome_cliente', 'email_cliente', 'itens', 'total', 'forma_pagamento'];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => "Campo obrigatório: $field"]);
            return;
        }
    }
    
    // Gerar número único do pedido
    $numero = generateOrderNumber($pdo);
    
    try {
        $pdo->beginTransaction();
        
        // Inserir pedido
        $stmt = $pdo->prepare("
            INSERT INTO pedidos (
                numero,
                usuario_id,
                nome_cliente,
                email_cliente,
                telefone_cliente,
                cpf_cliente,
                endereco_cep,
                endereco_logradouro,
                endereco_numero,
                endereco_complemento,
                endereco_bairro,
                endereco_cidade,
                endereco_estado,
                subtotal,
                desconto,
                frete,
                total,
                forma_pagamento,
                status,
                observacoes
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pendente', ?)
        ");
        
        $stmt->execute([
            $numero,
            $input['usuario_id'] ?? null,
            $input['nome_cliente'],
            $input['email_cliente'],
            $input['telefone_cliente'] ?? null,
            $input['cpf_cliente'] ?? null,
            $input['endereco']['cep'] ?? null,
            $input['endereco']['logradouro'] ?? null,
            $input['endereco']['numero'] ?? null,
            $input['endereco']['complemento'] ?? null,
            $input['endereco']['bairro'] ?? null,
            $input['endereco']['cidade'] ?? null,
            $input['endereco']['estado'] ?? null,
            $input['subtotal'] ?? $input['total'],
            $input['desconto'] ?? 0,
            $input['frete'] ?? 0,
            $input['total'],
            $input['forma_pagamento'],
            $input['observacoes'] ?? null
        ]);
        
        $pedidoId = $pdo->lastInsertId();
        
        // Inserir itens do pedido
        $stmtItem = $pdo->prepare("
            INSERT INTO pedido_itens (
                pedido_id,
                produto_id,
                produto_nome,
                produto_sku,
                produto_imagem,
                quantidade,
                preco_unitario,
                subtotal
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        foreach ($input['itens'] as $item) {
            $subtotalItem = ($item['preco_unitario'] ?? $item['price'] ?? 0) * ($item['quantidade'] ?? $item['quantity'] ?? 1);
            $stmtItem->execute([
                $pedidoId,
                $item['produto_id'] ?? $item['id'] ?? null,
                $item['nome'] ?? $item['name'] ?? 'Produto',
                $item['sku'] ?? null,
                $item['imagem'] ?? $item['image'] ?? null,
                $item['quantidade'] ?? $item['quantity'] ?? 1,
                $item['preco_unitario'] ?? $item['price'] ?? 0,
                $subtotalItem
            ]);
        }
        
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'data' => [
                'id' => $pedidoId,
                'numero' => $numero
            ],
            'message' => 'Pedido criado com sucesso'
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}

function generateOrderNumber($pdo) {
    $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $attempts = 0;
    $maxAttempts = 10;
    
    do {
        $numero = '';
        for ($i = 0; $i < 6; $i++) {
            $numero .= $characters[rand(0, strlen($characters) - 1)];
        }
        
        // Verificar se já existe
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM pedidos WHERE numero = ?");
        $stmt->execute([$numero]);
        $exists = $stmt->fetchColumn() > 0;
        
        $attempts++;
    } while ($exists && $attempts < $maxAttempts);
    
    if ($attempts >= $maxAttempts) {
        // Fallback: usar timestamp
        $numero = strtoupper(substr(md5(time() . rand()), 0, 6));
    }
    
    return $numero;
}
