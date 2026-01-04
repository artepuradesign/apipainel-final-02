-- =============================================
-- IPLACE SEMINOVOS - DATABASE SCHEMA
-- =============================================
-- Versão: 1.0.0
-- Data: 2024-01-15
-- Descrição: Schema completo do banco de dados para e-commerce de produtos Apple seminovos
-- =============================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- ENUMS
-- =============================================

-- Roles de usuário
CREATE TYPE public.app_role AS ENUM ('admin', 'moderator', 'user');

-- Status do pedido (fluxo completo)
CREATE TYPE public.order_status AS ENUM (
    'pending_payment',      -- Aguardando pagamento
    'pending_approval',     -- Aguardando aprovação (cartão)
    'payment_approved',     -- Pagamento aprovado
    'in_preparation',       -- Em preparação
    'shipped',              -- Enviado
    'in_transit',           -- Em rota de entrega
    'delivered',            -- Entregue
    'cancelled',            -- Cancelado
    'refunded'              -- Reembolsado
);

-- Método de pagamento
CREATE TYPE public.payment_method AS ENUM (
    'pix',
    'credit_card',
    'debit_card',
    'boleto'
);

-- Status do pagamento
CREATE TYPE public.payment_status AS ENUM (
    'pending',
    'processing',
    'approved',
    'declined',
    'cancelled',
    'refunded'
);

-- Condição do produto
CREATE TYPE public.product_condition AS ENUM (
    'excellent',    -- Excelente
    'very_good',    -- Muito Bom
    'good',         -- Bom
    'fair'          -- Regular
);

-- Categoria do produto
CREATE TYPE public.product_category AS ENUM (
    'iphone',
    'ipad',
    'mac',
    'apple_watch',
    'airpods',
    'accessories'
);

-- =============================================
-- TABELAS PRINCIPAIS
-- =============================================

-- Tabela de perfis de usuários
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    phone VARCHAR(20),
    cpf VARCHAR(14) UNIQUE,
    birth_date DATE,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de roles de usuários (separada por segurança)
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role app_role NOT NULL DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, role)
);

-- Tabela de endereços
CREATE TABLE public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    label VARCHAR(50) DEFAULT 'Principal',
    street VARCHAR(255) NOT NULL,
    number VARCHAR(20) NOT NULL,
    complement VARCHAR(100),
    neighborhood VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zip_code VARCHAR(9) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de categorias
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    parent_id UUID REFERENCES public.categories(id),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de produtos
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    short_description VARCHAR(500),
    category product_category NOT NULL,
    category_id UUID REFERENCES public.categories(id),
    condition product_condition NOT NULL DEFAULT 'excellent',
    
    -- Preços
    price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    
    -- Especificações
    capacity VARCHAR(20),           -- 64GB, 128GB, 256GB, etc.
    color VARCHAR(50),
    model VARCHAR(100),
    year INTEGER,
    battery_health INTEGER,         -- Saúde da bateria em %
    
    -- Estoque
    stock_quantity INTEGER DEFAULT 0,
    min_stock_alert INTEGER DEFAULT 2,
    
    -- Imagens
    main_image_url TEXT,
    
    -- SEO
    meta_title VARCHAR(70),
    meta_description VARCHAR(160),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Contadores
    view_count INTEGER DEFAULT 0,
    sold_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de imagens de produtos
CREATE TABLE public.product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT NOT NULL,
    alt_text VARCHAR(255),
    display_order INTEGER DEFAULT 0,
    is_main BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de especificações de produtos
CREATE TABLE public.product_specifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    spec_name VARCHAR(100) NOT NULL,
    spec_value VARCHAR(255) NOT NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de avaliações de produtos
CREATE TABLE public.product_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de carrinho de compras
CREATE TABLE public.cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, product_id)
);

-- Tabela de lista de desejos
CREATE TABLE public.wishlist_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, product_id)
);

-- Tabela de cupons de desconto
CREATE TABLE public.coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10, 2) NOT NULL,
    min_order_value DECIMAL(10, 2) DEFAULT 0,
    max_discount DECIMAL(10, 2),
    usage_limit INTEGER,
    usage_count INTEGER DEFAULT 0,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de pedidos (completa)
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(20) NOT NULL UNIQUE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    
    -- Dados do cliente (snapshot)
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    customer_cpf VARCHAR(14),
    
    -- Endereço de entrega (snapshot)
    shipping_street VARCHAR(255) NOT NULL,
    shipping_number VARCHAR(20) NOT NULL,
    shipping_complement VARCHAR(100),
    shipping_neighborhood VARCHAR(100) NOT NULL,
    shipping_city VARCHAR(100) NOT NULL,
    shipping_state VARCHAR(2) NOT NULL,
    shipping_zip_code VARCHAR(9) NOT NULL,
    
    -- Valores
    subtotal DECIMAL(10, 2) NOT NULL,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    
    -- Cupom
    coupon_id UUID REFERENCES public.coupons(id),
    coupon_code VARCHAR(50),
    
    -- Método de pagamento selecionado
    payment_method payment_method NOT NULL,
    
    -- Status do pedido (fluxo completo)
    status order_status DEFAULT 'pending_payment',
    
    -- Flags de controle
    requires_approval BOOLEAN DEFAULT FALSE,     -- TRUE para cartão
    is_approved BOOLEAN DEFAULT FALSE,
    approval_date TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES auth.users(id),
    
    -- Rastreamento
    tracking_code VARCHAR(100),
    tracking_url TEXT,
    carrier_name VARCHAR(100),
    estimated_delivery DATE,
    
    -- Notas
    customer_notes TEXT,
    admin_notes TEXT,
    cancellation_reason TEXT,
    
    -- Datas de cada etapa
    payment_confirmed_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    preparation_started_at TIMESTAMP WITH TIME ZONE,
    shipped_at TIMESTAMP WITH TIME ZONE,
    in_transit_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de itens do pedido
CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    
    -- Snapshot do produto
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(50),
    product_image_url TEXT,
    
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de pagamentos
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    
    method payment_method NOT NULL,
    status payment_status DEFAULT 'pending',
    
    amount DECIMAL(10, 2) NOT NULL,
    
    -- Dados do cartão (criptografados - apenas para processamento)
    card_holder_name VARCHAR(255),           -- Nome no cartão
    card_last_digits VARCHAR(4),             -- Últimos 4 dígitos
    card_brand VARCHAR(50),                  -- Visa, Mastercard, etc.
    card_expiry_month VARCHAR(2),            -- Mês de expiração (encriptado)
    card_expiry_year VARCHAR(4),             -- Ano de expiração (encriptado)
    card_token TEXT,                         -- Token do gateway (não armazenar número completo!)
    installments INTEGER DEFAULT 1,
    installment_value DECIMAL(10, 2),
    
    -- PIX
    pix_code TEXT,
    pix_qr_code_url TEXT,
    pix_expiration TIMESTAMP WITH TIME ZONE,
    
    -- Gateway de pagamento
    gateway_transaction_id VARCHAR(255),
    gateway_response JSONB,
    
    -- Datas
    paid_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de histórico do pedido (auditoria completa)
CREATE TABLE public.order_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    previous_status order_status,
    new_status order_status NOT NULL,
    notes TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_by_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de aprovações de pedidos (controle administrativo)
CREATE TABLE public.order_approvals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    payment_id UUID REFERENCES public.payments(id) ON DELETE CASCADE,
    
    -- Status da aprovação
    approval_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    
    -- Dados da análise
    risk_score INTEGER,                      -- Score de risco (0-100)
    risk_level VARCHAR(20),                  -- low, medium, high
    fraud_check_result JSONB,                -- Resultado da verificação antifraude
    
    -- Aprovação/Rejeição
    reviewed_by UUID REFERENCES auth.users(id),
    reviewed_by_name VARCHAR(255),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    
    -- Notas internas
    internal_notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de etapas de envio (rastreamento detalhado)
CREATE TABLE public.order_shipping_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    
    -- Tipo do evento
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'label_created',        -- Etiqueta criada
        'picked_up',            -- Coletado
        'in_transit',           -- Em trânsito
        'out_for_delivery',     -- Saiu para entrega
        'delivery_attempted',   -- Tentativa de entrega
        'delivered',            -- Entregue
        'returned'              -- Devolvido
    )),
    
    -- Detalhes
    description TEXT NOT NULL,
    location VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(2),
    
    -- Dados da transportadora
    carrier_code VARCHAR(100),
    carrier_status VARCHAR(255),
    
    event_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de notas fiscais
CREATE TABLE public.order_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    
    invoice_number VARCHAR(50) NOT NULL,
    invoice_series VARCHAR(10),
    invoice_key VARCHAR(50),                 -- Chave da NF-e
    invoice_url TEXT,                        -- URL para download
    
    issue_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de reembolsos
CREATE TABLE public.order_refunds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    payment_id UUID REFERENCES public.payments(id) ON DELETE CASCADE,
    
    amount DECIMAL(10, 2) NOT NULL,
    reason TEXT NOT NULL,
    
    -- Status do reembolso
    refund_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (refund_status IN ('pending', 'processing', 'completed', 'failed')),
    
    -- Gateway
    gateway_refund_id VARCHAR(255),
    gateway_response JSONB,
    
    -- Processamento
    processed_by UUID REFERENCES auth.users(id),
    processed_by_name VARCHAR(255),
    processed_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de configurações da loja
CREATE TABLE public.store_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) NOT NULL UNIQUE,
    value TEXT,
    description TEXT,
    updated_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de banners
CREATE TABLE public.banners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    subtitle TEXT,
    image_url TEXT NOT NULL,
    link_url TEXT,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de FAQ
CREATE TABLE public.faqs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category VARCHAR(100),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de contatos/leads
CREATE TABLE public.contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    subject VARCHAR(255),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    replied_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de newsletter
CREATE TABLE public.newsletter_subscribers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    unsubscribed_at TIMESTAMP WITH TIME ZONE
);

-- =============================================
-- ÍNDICES
-- =============================================

-- Produtos
CREATE INDEX idx_products_category ON public.products(category);
CREATE INDEX idx_products_slug ON public.products(slug);
CREATE INDEX idx_products_is_active ON public.products(is_active);
CREATE INDEX idx_products_is_featured ON public.products(is_featured);
CREATE INDEX idx_products_price ON public.products(price);
CREATE INDEX idx_products_created_at ON public.products(created_at DESC);

-- Pedidos
CREATE INDEX idx_orders_user_id ON public.orders(user_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_order_number ON public.orders(order_number);
CREATE INDEX idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX idx_orders_requires_approval ON public.orders(requires_approval);
CREATE INDEX idx_orders_payment_method ON public.orders(payment_method);

-- Pagamentos
CREATE INDEX idx_payments_order_id ON public.payments(order_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_payments_method ON public.payments(method);

-- Aprovações
CREATE INDEX idx_order_approvals_order_id ON public.order_approvals(order_id);
CREATE INDEX idx_order_approvals_status ON public.order_approvals(approval_status);

-- Histórico
CREATE INDEX idx_order_history_order_id ON public.order_history(order_id);
CREATE INDEX idx_order_history_created_at ON public.order_history(created_at DESC);

-- Eventos de envio
CREATE INDEX idx_order_shipping_events_order_id ON public.order_shipping_events(order_id);

-- Reembolsos
CREATE INDEX idx_order_refunds_order_id ON public.order_refunds(order_id);
CREATE INDEX idx_order_refunds_status ON public.order_refunds(refund_status);

-- Usuários
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_user_roles_user_id ON public.user_roles(user_id);

-- =============================================
-- FUNÇÕES
-- =============================================

-- Função para verificar role do usuário (evita recursão RLS)
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles
        WHERE user_id = _user_id
        AND role = _role
    )
$$;

-- Função para gerar número do pedido
CREATE OR REPLACE FUNCTION public.generate_order_number()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    new_number TEXT;
BEGIN
    new_number := 'IP' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                  LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    RETURN new_number;
END;
$$;

-- Trigger para gerar número do pedido automaticamente
CREATE OR REPLACE FUNCTION public.set_order_number()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.order_number IS NULL THEN
        NEW.order_number := public.generate_order_number();
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_set_order_number
    BEFORE INSERT ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.set_order_number();

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Aplicar trigger de updated_at nas tabelas
CREATE TRIGGER trigger_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_addresses_updated_at
    BEFORE UPDATE ON public.addresses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_payments_updated_at
    BEFORE UPDATE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_order_approvals_updated_at
    BEFORE UPDATE ON public.order_approvals
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_order_refunds_updated_at
    BEFORE UPDATE ON public.order_refunds
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- Função para atualizar estoque após pagamento aprovado
CREATE OR REPLACE FUNCTION public.update_stock_on_payment()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status = 'payment_approved' AND OLD.status IN ('pending_payment', 'pending_approval') THEN
        UPDATE public.products
        SET stock_quantity = stock_quantity - oi.quantity,
            sold_count = sold_count + oi.quantity
        FROM public.order_items oi
        WHERE oi.order_id = NEW.id
        AND products.id = oi.product_id;
    END IF;
    
    -- Restaurar estoque em caso de cancelamento
    IF NEW.status = 'cancelled' AND OLD.status NOT IN ('cancelled', 'refunded') THEN
        UPDATE public.products
        SET stock_quantity = stock_quantity + oi.quantity,
            sold_count = GREATEST(0, sold_count - oi.quantity)
        FROM public.order_items oi
        WHERE oi.order_id = NEW.id
        AND products.id = oi.product_id;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_update_stock_on_payment
    AFTER UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.update_stock_on_payment();

-- Função para registrar histórico do pedido com detalhes
CREATE OR REPLACE FUNCTION public.log_order_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.order_history (order_id, previous_status, new_status)
        VALUES (NEW.id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_log_order_status
    AFTER UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.log_order_status_change();

-- Função para definir status inicial baseado no método de pagamento
CREATE OR REPLACE FUNCTION public.set_initial_order_status()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- PIX: vai direto para pagamento pendente (após confirmação, vai para aprovado)
    -- Cartão: precisa de aprovação manual
    IF NEW.payment_method = 'pix' THEN
        NEW.requires_approval := FALSE;
    ELSIF NEW.payment_method IN ('credit_card', 'debit_card') THEN
        NEW.requires_approval := TRUE;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_set_initial_order_status
    BEFORE INSERT ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.set_initial_order_status();

-- Função para aprovar pedido (PIX confirmado automaticamente)
CREATE OR REPLACE FUNCTION public.approve_pix_payment()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Quando pagamento PIX é aprovado, atualiza o pedido
    IF NEW.method = 'pix' AND NEW.status = 'approved' AND OLD.status = 'pending' THEN
        UPDATE public.orders
        SET status = 'payment_approved',
            payment_confirmed_at = NOW()
        WHERE id = NEW.order_id;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_approve_pix_payment
    AFTER UPDATE ON public.payments
    FOR EACH ROW
    EXECUTE FUNCTION public.approve_pix_payment();

-- Função administrativa para atualizar status do pedido
CREATE OR REPLACE FUNCTION public.admin_update_order_status(
    _order_id UUID,
    _new_status order_status,
    _admin_id UUID,
    _notes TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    current_order RECORD;
BEGIN
    -- Verificar se é admin
    IF NOT public.has_role(_admin_id, 'admin') THEN
        RAISE EXCEPTION 'Apenas administradores podem atualizar o status do pedido';
    END IF;
    
    -- Obter pedido atual
    SELECT * INTO current_order FROM public.orders WHERE id = _order_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido não encontrado';
    END IF;
    
    -- Atualizar status e data correspondente
    UPDATE public.orders
    SET status = _new_status,
        admin_notes = COALESCE(_notes, admin_notes),
        approved_at = CASE WHEN _new_status = 'payment_approved' THEN NOW() ELSE approved_at END,
        approved_by = CASE WHEN _new_status = 'payment_approved' THEN _admin_id ELSE approved_by END,
        is_approved = CASE WHEN _new_status = 'payment_approved' THEN TRUE ELSE is_approved END,
        preparation_started_at = CASE WHEN _new_status = 'in_preparation' THEN NOW() ELSE preparation_started_at END,
        shipped_at = CASE WHEN _new_status = 'shipped' THEN NOW() ELSE shipped_at END,
        in_transit_at = CASE WHEN _new_status = 'in_transit' THEN NOW() ELSE in_transit_at END,
        delivered_at = CASE WHEN _new_status = 'delivered' THEN NOW() ELSE delivered_at END,
        cancelled_at = CASE WHEN _new_status = 'cancelled' THEN NOW() ELSE cancelled_at END,
        refunded_at = CASE WHEN _new_status = 'refunded' THEN NOW() ELSE refunded_at END
    WHERE id = _order_id;
    
    -- Registrar no histórico com detalhes do admin
    INSERT INTO public.order_history (order_id, previous_status, new_status, notes, created_by, created_by_name)
    SELECT _order_id, current_order.status, _new_status, _notes, _admin_id, p.full_name
    FROM public.profiles p WHERE p.id = _admin_id;
    
    RETURN TRUE;
END;
$$;

-- Função para aprovar pagamento com cartão
CREATE OR REPLACE FUNCTION public.admin_approve_card_payment(
    _order_id UUID,
    _admin_id UUID,
    _notes TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Verificar se é admin
    IF NOT public.has_role(_admin_id, 'admin') THEN
        RAISE EXCEPTION 'Apenas administradores podem aprovar pagamentos';
    END IF;
    
    -- Atualizar pedido
    UPDATE public.orders
    SET status = 'payment_approved',
        is_approved = TRUE,
        approval_date = NOW(),
        approved_by = _admin_id,
        approved_at = NOW(),
        admin_notes = COALESCE(_notes, admin_notes)
    WHERE id = _order_id
    AND requires_approval = TRUE
    AND status = 'pending_approval';
    
    -- Atualizar aprovação
    UPDATE public.order_approvals
    SET approval_status = 'approved',
        reviewed_by = _admin_id,
        reviewed_at = NOW(),
        internal_notes = _notes
    WHERE order_id = _order_id;
    
    -- Atualizar pagamento
    UPDATE public.payments
    SET status = 'approved',
        paid_at = NOW()
    WHERE order_id = _order_id;
    
    RETURN TRUE;
END;
$$;

-- Função para rejeitar pagamento com cartão
CREATE OR REPLACE FUNCTION public.admin_reject_card_payment(
    _order_id UUID,
    _admin_id UUID,
    _rejection_reason TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Verificar se é admin
    IF NOT public.has_role(_admin_id, 'admin') THEN
        RAISE EXCEPTION 'Apenas administradores podem rejeitar pagamentos';
    END IF;
    
    -- Atualizar pedido
    UPDATE public.orders
    SET status = 'cancelled',
        cancellation_reason = _rejection_reason,
        cancelled_at = NOW()
    WHERE id = _order_id
    AND requires_approval = TRUE;
    
    -- Atualizar aprovação
    UPDATE public.order_approvals
    SET approval_status = 'rejected',
        reviewed_by = _admin_id,
        reviewed_at = NOW(),
        rejection_reason = _rejection_reason
    WHERE order_id = _order_id;
    
    -- Atualizar pagamento
    UPDATE public.payments
    SET status = 'declined'
    WHERE order_id = _order_id;
    
    RETURN TRUE;
END;
$$;

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_shipping_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_refunds ENABLE ROW LEVEL SECURITY;

-- Políticas para profiles
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para user_roles (somente admins)
CREATE POLICY "Only admins can manage roles"
    ON public.user_roles FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para produtos (públicos para leitura)
CREATE POLICY "Anyone can view active products"
    ON public.products FOR SELECT
    TO anon, authenticated
    USING (is_active = TRUE);

CREATE POLICY "Admins can manage products"
    ON public.products FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para imagens de produtos
CREATE POLICY "Anyone can view product images"
    ON public.product_images FOR SELECT
    TO anon, authenticated
    USING (TRUE);

CREATE POLICY "Admins can manage product images"
    ON public.product_images FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para carrinho
CREATE POLICY "Users can manage own cart"
    ON public.cart_items FOR ALL
    TO authenticated
    USING (auth.uid() = user_id);

-- Políticas para lista de desejos
CREATE POLICY "Users can manage own wishlist"
    ON public.wishlist_items FOR ALL
    TO authenticated
    USING (auth.uid() = user_id);

-- Políticas para pedidos
CREATE POLICY "Users can view own orders"
    ON public.orders FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own orders"
    ON public.orders FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can manage all orders"
    ON public.orders FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para itens do pedido
CREATE POLICY "Users can view own order items"
    ON public.order_items FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all order items"
    ON public.order_items FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para pagamentos
CREATE POLICY "Users can view own payments"
    ON public.payments FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = payments.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all payments"
    ON public.payments FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para histórico de pedidos
CREATE POLICY "Users can view own order history"
    ON public.order_history FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_history.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all order history"
    ON public.order_history FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para aprovações (somente admins)
CREATE POLICY "Only admins can manage order approvals"
    ON public.order_approvals FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para eventos de envio
CREATE POLICY "Users can view own shipping events"
    ON public.order_shipping_events FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_shipping_events.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all shipping events"
    ON public.order_shipping_events FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para notas fiscais
CREATE POLICY "Users can view own invoices"
    ON public.order_invoices FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_invoices.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all invoices"
    ON public.order_invoices FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para reembolsos
CREATE POLICY "Users can view own refunds"
    ON public.order_refunds FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders o
            JOIN public.order_refunds r ON o.id = r.order_id
            WHERE o.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all refunds"
    ON public.order_refunds FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- Políticas para endereços
CREATE POLICY "Users can manage own addresses"
    ON public.addresses FOR ALL
    TO authenticated
    USING (auth.uid() = user_id);

-- Políticas para avaliações
CREATE POLICY "Anyone can view approved reviews"
    ON public.product_reviews FOR SELECT
    TO anon, authenticated
    USING (is_approved = TRUE);

CREATE POLICY "Users can create reviews"
    ON public.product_reviews FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
    ON public.product_reviews FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all reviews"
    ON public.product_reviews FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'));

-- =============================================
-- DADOS INICIAIS
-- =============================================

-- Categorias iniciais
INSERT INTO public.categories (name, slug, description, display_order) VALUES
('iPhone', 'iphone', 'Smartphones Apple iPhone seminovos', 1),
('iPad', 'ipad', 'Tablets Apple iPad seminovos', 2),
('Mac', 'mac', 'Computadores Mac seminovos', 3),
('Apple Watch', 'apple-watch', 'Relógios Apple Watch seminovos', 4),
('AirPods', 'airpods', 'Fones AirPods seminovos', 5),
('Acessórios', 'acessorios', 'Acessórios Apple seminovos', 6);

-- Configurações iniciais da loja
INSERT INTO public.store_settings (key, value, description) VALUES
('store_name', 'iPlace Seminovos', 'Nome da loja'),
('store_email', 'contato@iplaceseminovos.com.br', 'Email de contato'),
('store_phone', '(11) 4020-2595', 'Telefone de contato'),
('store_whatsapp', '5511999999999', 'WhatsApp da loja'),
('free_shipping_min', '500', 'Valor mínimo para frete grátis'),
('pix_discount', '5', 'Desconto em % para pagamento via PIX');

-- FAQs iniciais
INSERT INTO public.faqs (question, answer, category, display_order) VALUES
('Qual a garantia dos produtos seminovos?', 'Todos os nossos produtos possuem 3 meses de garantia contra defeitos de fabricação.', 'Garantia', 1),
('Como funciona a bateria dos iPhones seminovos?', 'Todos os iPhones são comercializados com saúde da bateria acima de 80%, garantindo excelente desempenho.', 'Produtos', 2),
('Posso trocar meu aparelho usado?', 'Sim! Aceitamos aparelhos usados como parte do pagamento através do programa Buyback.', 'Buyback', 3),
('Qual o prazo de entrega?', 'O prazo de entrega varia de 3 a 10 dias úteis, dependendo da região.', 'Entrega', 4),
('Como funciona a devolução?', 'Você tem até 7 dias após o recebimento para solicitar a devolução sem custos.', 'Devolução', 5);

-- =============================================
-- FIM DO SCHEMA
-- =============================================
