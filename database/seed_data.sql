-- =====================================================
-- DADOS DE EXEMPLO PARA IPLACE SEMINOVOS
-- Execute este arquivo APÓS criar as tabelas do schema_mysql.sql
-- =====================================================

SET NAMES utf8mb4;

-- =====================================================
-- USUÁRIO ADMIN (senha: admin123)
-- =====================================================
INSERT INTO profiles (id, email, full_name, phone) VALUES
('11111111-1111-1111-1111-111111111111', 'admin@iplace.com.br', 'Administrador', '(11) 99999-9999');

INSERT INTO user_roles (user_id, role) VALUES
('11111111-1111-1111-1111-111111111111', 'admin');

-- =====================================================
-- CATEGORIAS
-- =====================================================
INSERT INTO categories (id, name, slug, description, sort_order, is_active) VALUES
('cat-iphone-0001', 'iPhone', 'iphone', 'Smartphones Apple iPhone seminovos com garantia', 1, TRUE),
('cat-ipad-00001', 'iPad', 'ipad', 'Tablets Apple iPad seminovos com garantia', 2, TRUE),
('cat-mac-000001', 'Mac', 'mac', 'Computadores Apple Mac seminovos com garantia', 3, TRUE),
('cat-watch-0001', 'Apple Watch', 'apple-watch', 'Relógios Apple Watch seminovos com garantia', 4, TRUE),
('cat-airpods-01', 'AirPods', 'airpods', 'Fones Apple AirPods seminovos com garantia', 5, TRUE),
('cat-acessorio1', 'Acessórios', 'acessorios', 'Acessórios Apple originais', 6, TRUE);

-- =====================================================
-- PRODUTOS
-- =====================================================
INSERT INTO products (id, sku, name, slug, description, short_description, category_id, category, condition_type, condition_description, price, original_price, discount_percent, stock, warranty_months, is_active, is_featured, main_image) VALUES

-- iPhones
('prod-iph15pro-001', 'IPH15PRO256', 'iPhone 15 Pro 256GB', 'iphone-15-pro-256gb', 
 'iPhone 15 Pro com chip A17 Pro, câmera de 48MP, Dynamic Island e corpo em titânio. Aparelho em excelente estado, funcionamento perfeito. Bateria com 95% de saúde. Acompanha cabo USB-C original.', 
 'iPhone 15 Pro 256GB seminovo em excelente estado com garantia de 6 meses', 
 'cat-iphone-0001', 'iphone', 'excelente', 'Excelente - Sem marcas de uso visíveis', 
 6499.00, 7999.00, 19, 5, 6, TRUE, TRUE, 
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-1inch-naturaltitanium?wid=800&hei=800&fmt=jpeg&qlt=90'),

('prod-iph14pls-001', 'IPH14PLUS128', 'iPhone 14 Plus 128GB', 'iphone-14-plus-128gb', 
 'iPhone 14 Plus com tela de 6.7 polegadas, chip A15 Bionic e câmera dupla de 12MP. Bateria com saúde acima de 85%. Aparelho em ótimo estado de conservação.',
 'iPhone 14 Plus 128GB seminovo em ótimo estado',
 'cat-iphone-0001', 'iphone', 'muito_bom', 'Muito Bom - Pequenas marcas de uso',
 4299.00, 5499.00, 22, 8, 6, TRUE, TRUE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-14-finish-select-202209-6-7inch-blue?wid=800&hei=800&fmt=jpeg&qlt=90'),

('prod-iph13-00001', 'IPH13128', 'iPhone 13 128GB', 'iphone-13-128gb',
 'iPhone 13 com chip A15 Bionic, câmera dupla de 12MP e 5G. Aparelho funcionando perfeitamente. Bateria com 82% de saúde.',
 'iPhone 13 128GB seminovo funcionando perfeitamente',
 'cat-iphone-0001', 'iphone', 'bom', 'Bom - Marcas leves de uso',
 2999.00, 3999.00, 25, 12, 3, TRUE, FALSE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-13-finish-select-202207-pink?wid=800&hei=800&fmt=jpeg&qlt=90'),

('prod-iph12-00001', 'IPH12128', 'iPhone 12 128GB', 'iphone-12-128gb',
 'iPhone 12 com chip A14 Bionic, tela Super Retina XDR e 5G. Excelente custo-benefício. Bateria com 80% de saúde.',
 'iPhone 12 128GB seminovo com ótimo custo-benefício',
 'cat-iphone-0001', 'iphone', 'bom', 'Bom - Algumas marcas de uso',
 2199.00, 2999.00, 27, 15, 3, TRUE, FALSE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-12-black-select-2020?wid=800&hei=800&fmt=jpeg&qlt=90'),

-- iPads
('prod-ipadpro-001', 'IPADPRO11M2', 'iPad Pro 11" M2 256GB', 'ipad-pro-11-m2-256gb',
 'iPad Pro 11 polegadas com chip M2, tela Liquid Retina XDR e compatível com Apple Pencil 2. Ideal para profissionais e criadores de conteúdo.',
 'iPad Pro 11" M2 256GB seminovo em excelente estado',
 'cat-ipad-00001', 'ipad', 'excelente', 'Excelente - Como novo',
 6299.00, 7999.00, 21, 3, 6, TRUE, TRUE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/ipad-pro-finish-select-202210-11inch-space-gray-wifi?wid=800&hei=800&fmt=jpeg&qlt=90'),

('prod-ipadair-001', 'IPADAIR5256', 'iPad Air 5ª Geração 256GB', 'ipad-air-5-256gb',
 'iPad Air com chip M1, tela Liquid Retina de 10.9" e compatível com Magic Keyboard. Performance impressionante para trabalho e entretenimento.',
 'iPad Air 5ª Geração 256GB seminovo',
 'cat-ipad-00001', 'ipad', 'muito_bom', 'Muito Bom - Pequenas marcas',
 4499.00, 5699.00, 21, 6, 6, TRUE, FALSE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/ipad-air-finish-select-gallery-202211-blue-wifi?wid=800&hei=800&fmt=jpeg&qlt=90'),

-- Macs
('prod-mbpro14-001', 'MBPROM2PRO14', 'MacBook Pro 14" M2 Pro 512GB', 'macbook-pro-14-m2-pro-512gb',
 'MacBook Pro 14 polegadas com chip M2 Pro, 16GB RAM, SSD 512GB. Bateria com ciclos baixos. Performance profissional para edição de vídeo e desenvolvimento.',
 'MacBook Pro 14" M2 Pro 512GB seminovo em excelente estado',
 'cat-mac-000001', 'mac', 'excelente', 'Excelente - Pouquíssimo uso',
 12499.00, 15999.00, 22, 2, 6, TRUE, TRUE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/mbp14-spacegray-select-202310?wid=800&hei=800&fmt=jpeg&qlt=90'),

('prod-mbair-0001', 'MBAIRM2256', 'MacBook Air M2 256GB', 'macbook-air-m2-256gb',
 'MacBook Air com chip M2, 8GB RAM, SSD 256GB. Design ultrafino e bateria de longa duração. Silencioso e potente.',
 'MacBook Air M2 256GB seminovo',
 'cat-mac-000001', 'mac', 'muito_bom', 'Muito Bom - Marcas leves',
 7499.00, 9499.00, 21, 4, 6, TRUE, FALSE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/mba-midnight-select-202306?wid=800&hei=800&fmt=jpeg&qlt=90'),

-- Apple Watch
('prod-aws9-00001', 'AWS9GPS45', 'Apple Watch Series 9 GPS 45mm', 'apple-watch-series-9-gps-45mm',
 'Apple Watch Series 9 com GPS, caixa de alumínio e pulseira esportiva. Chip S9 SiP com Neural Engine de 4 núcleos.',
 'Apple Watch Series 9 GPS 45mm seminovo',
 'cat-watch-0001', 'apple_watch', 'excelente', 'Excelente - Sem marcas',
 2899.00, 3699.00, 22, 7, 6, TRUE, TRUE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/watch-s9-702w-702?wid=800&hei=800&fmt=jpeg&qlt=90'),

('prod-awu2-00001', 'AWULTRA2', 'Apple Watch Ultra 2', 'apple-watch-ultra-2',
 'Apple Watch Ultra 2 com GPS + Celular, caixa de titânio 49mm. Ideal para esportes extremos e aventuras.',
 'Apple Watch Ultra 2 seminovo',
 'cat-watch-0001', 'apple_watch', 'excelente', 'Excelente - Como novo',
 5499.00, 6999.00, 21, 2, 6, TRUE, TRUE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/watch-ultra-702?wid=800&hei=800&fmt=jpeg&qlt=90'),

-- AirPods
('prod-appmax-001', 'APPMAX', 'AirPods Max', 'airpods-max',
 'AirPods Max com cancelamento de ruído ativo, áudio espacial e até 20h de bateria. Qualidade de som excepcional.',
 'AirPods Max seminovo',
 'cat-airpods-01', 'acessorios', 'muito_bom', 'Muito Bom - Pequenas marcas',
 2999.00, 4299.00, 30, 4, 3, TRUE, FALSE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/airpods-max-select-spacegray-202011?wid=800&hei=800&fmt=jpeg&qlt=90'),

('prod-apppro2-01', 'APPPRO2', 'AirPods Pro 2ª Geração', 'airpods-pro-2-geracao',
 'AirPods Pro 2ª geração com cancelamento de ruído, modo transparência e estojo MagSafe. Som imersivo e confortável.',
 'AirPods Pro 2ª Geração seminovo',
 'cat-airpods-01', 'acessorios', 'excelente', 'Excelente - Pouquíssimo uso',
 1499.00, 1899.00, 21, 10, 3, TRUE, TRUE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQD83?wid=800&hei=800&fmt=jpeg&qlt=90'),

-- Acessórios
('prod-magsafe-01', 'MAGSAFE15W', 'Carregador MagSafe 15W Original', 'carregador-magsafe-15w-original',
 'Carregador MagSafe original Apple com potência de 15W. Compatível com iPhone 12 e posteriores. Lacrado na caixa.',
 'Carregador MagSafe 15W Original novo lacrado',
 'cat-acessorio1', 'acessorios', 'excelente', 'Novo - Lacrado',
 299.00, 399.00, 25, 25, 12, TRUE, FALSE,
 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MHXH3?wid=800&hei=800&fmt=jpeg&qlt=90');

-- =====================================================
-- ESPECIFICAÇÕES DOS PRODUTOS
-- =====================================================
INSERT INTO product_specifications (product_id, spec_key, spec_value, sort_order) VALUES
-- iPhone 15 Pro
('prod-iph15pro-001', 'Armazenamento', '256GB', 1),
('prod-iph15pro-001', 'Chip', 'A17 Pro', 2),
('prod-iph15pro-001', 'Tela', '6.1" Super Retina XDR', 3),
('prod-iph15pro-001', 'Câmera', '48MP + 12MP + 12MP', 4),
('prod-iph15pro-001', 'Bateria', 'Saúde 95%', 5),
('prod-iph15pro-001', 'Cor', 'Titânio Natural', 6),

-- iPhone 14 Plus
('prod-iph14pls-001', 'Armazenamento', '128GB', 1),
('prod-iph14pls-001', 'Chip', 'A15 Bionic', 2),
('prod-iph14pls-001', 'Tela', '6.7" Super Retina XDR', 3),
('prod-iph14pls-001', 'Câmera', '12MP + 12MP', 4),
('prod-iph14pls-001', 'Bateria', 'Saúde 88%', 5),
('prod-iph14pls-001', 'Cor', 'Azul', 6),

-- iPhone 13
('prod-iph13-00001', 'Armazenamento', '128GB', 1),
('prod-iph13-00001', 'Chip', 'A15 Bionic', 2),
('prod-iph13-00001', 'Tela', '6.1" Super Retina XDR', 3),
('prod-iph13-00001', 'Câmera', '12MP + 12MP', 4),
('prod-iph13-00001', 'Bateria', 'Saúde 82%', 5),
('prod-iph13-00001', 'Cor', 'Rosa', 6),

-- iPhone 12
('prod-iph12-00001', 'Armazenamento', '128GB', 1),
('prod-iph12-00001', 'Chip', 'A14 Bionic', 2),
('prod-iph12-00001', 'Tela', '6.1" Super Retina XDR', 3),
('prod-iph12-00001', 'Câmera', '12MP + 12MP', 4),
('prod-iph12-00001', 'Bateria', 'Saúde 80%', 5),
('prod-iph12-00001', 'Cor', 'Preto', 6),

-- iPad Pro
('prod-ipadpro-001', 'Armazenamento', '256GB', 1),
('prod-ipadpro-001', 'Chip', 'M2', 2),
('prod-ipadpro-001', 'Tela', '11" Liquid Retina XDR', 3),
('prod-ipadpro-001', 'Conectividade', 'Wi-Fi', 4),
('prod-ipadpro-001', 'Cor', 'Cinza Espacial', 5),

-- iPad Air
('prod-ipadair-001', 'Armazenamento', '256GB', 1),
('prod-ipadair-001', 'Chip', 'M1', 2),
('prod-ipadair-001', 'Tela', '10.9" Liquid Retina', 3),
('prod-ipadair-001', 'Conectividade', 'Wi-Fi', 4),
('prod-ipadair-001', 'Cor', 'Azul', 5),

-- MacBook Pro
('prod-mbpro14-001', 'Armazenamento', '512GB SSD', 1),
('prod-mbpro14-001', 'Chip', 'M2 Pro', 2),
('prod-mbpro14-001', 'Memória', '16GB RAM', 3),
('prod-mbpro14-001', 'Tela', '14.2" Liquid Retina XDR', 4),
('prod-mbpro14-001', 'Cor', 'Cinza Espacial', 5),

-- MacBook Air
('prod-mbair-0001', 'Armazenamento', '256GB SSD', 1),
('prod-mbair-0001', 'Chip', 'M2', 2),
('prod-mbair-0001', 'Memória', '8GB RAM', 3),
('prod-mbair-0001', 'Tela', '13.6" Liquid Retina', 4),
('prod-mbair-0001', 'Cor', 'Meia-Noite', 5),

-- Apple Watch Series 9
('prod-aws9-00001', 'Tamanho', '45mm', 1),
('prod-aws9-00001', 'Material', 'Alumínio', 2),
('prod-aws9-00001', 'Conectividade', 'GPS', 3),
('prod-aws9-00001', 'Chip', 'S9 SiP', 4),

-- Apple Watch Ultra 2
('prod-awu2-00001', 'Tamanho', '49mm', 1),
('prod-awu2-00001', 'Material', 'Titânio', 2),
('prod-awu2-00001', 'Conectividade', 'GPS + Celular', 3),
('prod-awu2-00001', 'Chip', 'S9 SiP', 4),

-- AirPods Max
('prod-appmax-001', 'Tipo', 'Over-ear', 1),
('prod-appmax-001', 'Cancelamento de Ruído', 'Ativo', 2),
('prod-appmax-001', 'Bateria', 'Até 20 horas', 3),
('prod-appmax-001', 'Cor', 'Cinza Espacial', 4),

-- AirPods Pro 2
('prod-apppro2-01', 'Tipo', 'In-ear', 1),
('prod-apppro2-01', 'Cancelamento de Ruído', 'Ativo', 2),
('prod-apppro2-01', 'Estojo', 'MagSafe', 3),
('prod-apppro2-01', 'Bateria', 'Até 6 horas', 4),

-- MagSafe
('prod-magsafe-01', 'Potência', '15W', 1),
('prod-magsafe-01', 'Compatibilidade', 'iPhone 12 e posteriores', 2),
('prod-magsafe-01', 'Tipo', 'Carregador sem fio', 3);

-- =====================================================
-- CONFIGURAÇÕES DA LOJA
-- =====================================================
INSERT INTO store_settings (setting_key, setting_value, setting_type, description) VALUES
('store_name', 'iPlace Seminovos', 'string', 'Nome da loja'),
('store_phone', '(11) 99999-9999', 'string', 'Telefone da loja'),
('store_whatsapp', '5511999999999', 'string', 'WhatsApp da loja'),
('store_email', 'contato@iplaceseminovos.com.br', 'string', 'Email da loja'),
('free_shipping_min', '500', 'number', 'Valor mínimo para frete grátis'),
('max_installments', '12', 'number', 'Número máximo de parcelas'),
('interest_free_installments', '6', 'number', 'Número de parcelas sem juros');
