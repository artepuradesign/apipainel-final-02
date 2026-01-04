-- =============================================
-- IPLACE SEMINOVOS - DATABASE SCHEMA (MySQL)
-- =============================================
-- Versão: 1.0.0
-- Data: 2024-01-15
-- Descrição: Schema completo do banco de dados para e-commerce de produtos Apple seminovos
-- Compatível com MySQL 5.7+ / MariaDB 10.2+
-- =============================================

-- Configurações iniciais
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- TABELAS PRINCIPAIS
-- =============================================

-- Tabela de usuários/perfis
DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `email` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(255) NULL,
  `phone` VARCHAR(20) NULL,
  `cpf` VARCHAR(14) NULL,
  `avatar_url` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_profiles_email` (`email`),
  UNIQUE KEY `uk_profiles_cpf` (`cpf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de roles de usuários
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `user_id` CHAR(36) NOT NULL,
  `role` ENUM('admin', 'customer', 'manager') NOT NULL DEFAULT 'customer',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_roles` (`user_id`, `role`),
  KEY `idx_user_roles_user_id` (`user_id`),
  CONSTRAINT `fk_user_roles_user` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de endereços
DROP TABLE IF EXISTS `addresses`;
CREATE TABLE `addresses` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `user_id` CHAR(36) NOT NULL,
  `label` VARCHAR(50) NULL DEFAULT 'Casa',
  `recipient_name` VARCHAR(255) NOT NULL,
  `street` VARCHAR(255) NOT NULL,
  `number` VARCHAR(20) NOT NULL,
  `complement` VARCHAR(100) NULL,
  `neighborhood` VARCHAR(100) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `state` CHAR(2) NOT NULL,
  `zip_code` VARCHAR(9) NOT NULL,
  `phone` VARCHAR(20) NULL,
  `is_default` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_addresses_user_id` (`user_id`),
  CONSTRAINT `fk_addresses_user` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de categorias
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `image_url` TEXT NULL,
  `parent_id` CHAR(36) NULL,
  `sort_order` INT DEFAULT 0,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_categories_slug` (`slug`),
  KEY `idx_categories_parent` (`parent_id`),
  CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de produtos
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `sku` VARCHAR(50) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `short_description` VARCHAR(500) NULL,
  `category_id` CHAR(36) NULL,
  `category` ENUM('iphone', 'ipad', 'mac', 'apple_watch', 'acessorios') NOT NULL,
  `condition_type` ENUM('excelente', 'muito_bom', 'bom', 'aceitavel') NOT NULL DEFAULT 'muito_bom',
  `condition_description` TEXT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `original_price` DECIMAL(10,2) NULL,
  `cost_price` DECIMAL(10,2) NULL,
  `discount_percent` INT NULL,
  `stock` INT NOT NULL DEFAULT 0,
  `reserved_stock` INT NOT NULL DEFAULT 0,
  `sold_count` INT NOT NULL DEFAULT 0,
  `main_image` TEXT NULL,
  `warranty_months` INT DEFAULT 12,
  `weight_kg` DECIMAL(5,3) NULL,
  `dimensions_cm` VARCHAR(50) NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_featured` BOOLEAN DEFAULT FALSE,
  `meta_title` VARCHAR(255) NULL,
  `meta_description` VARCHAR(500) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_products_sku` (`sku`),
  UNIQUE KEY `uk_products_slug` (`slug`),
  KEY `idx_products_category` (`category`),
  KEY `idx_products_category_id` (`category_id`),
  KEY `idx_products_active` (`is_active`),
  KEY `idx_products_featured` (`is_featured`),
  KEY `idx_products_price` (`price`),
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de imagens de produtos
DROP TABLE IF EXISTS `product_images`;
CREATE TABLE `product_images` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `product_id` CHAR(36) NOT NULL,
  `image_url` TEXT NOT NULL,
  `alt_text` VARCHAR(255) NULL,
  `sort_order` INT DEFAULT 0,
  `is_primary` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_images_product` (`product_id`),
  CONSTRAINT `fk_product_images_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de especificações de produtos
DROP TABLE IF EXISTS `product_specifications`;
CREATE TABLE `product_specifications` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `product_id` CHAR(36) NOT NULL,
  `spec_key` VARCHAR(100) NOT NULL,
  `spec_value` VARCHAR(255) NOT NULL,
  `sort_order` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_product_specs_product` (`product_id`),
  CONSTRAINT `fk_product_specs_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de avaliações de produtos
DROP TABLE IF EXISTS `product_reviews`;
CREATE TABLE `product_reviews` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `product_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `order_id` CHAR(36) NULL,
  `rating` TINYINT NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
  `title` VARCHAR(255) NULL,
  `comment` TEXT NULL,
  `is_verified_purchase` BOOLEAN DEFAULT FALSE,
  `is_approved` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reviews_product` (`product_id`),
  KEY `idx_reviews_user` (`user_id`),
  CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de itens do carrinho
DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE `cart_items` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `user_id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cart_items` (`user_id`, `product_id`),
  KEY `idx_cart_items_user` (`user_id`),
  CONSTRAINT `fk_cart_items_user` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de lista de desejos
DROP TABLE IF EXISTS `wishlist_items`;
CREATE TABLE `wishlist_items` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `user_id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_wishlist_items` (`user_id`, `product_id`),
  KEY `idx_wishlist_user` (`user_id`),
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wishlist_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de cupons
DROP TABLE IF EXISTS `coupons`;
CREATE TABLE `coupons` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `code` VARCHAR(50) NOT NULL,
  `description` VARCHAR(255) NULL,
  `discount_type` ENUM('percentage', 'fixed') NOT NULL,
  `discount_value` DECIMAL(10,2) NOT NULL,
  `min_purchase` DECIMAL(10,2) NULL,
  `max_discount` DECIMAL(10,2) NULL,
  `max_uses` INT NULL,
  `used_count` INT DEFAULT 0,
  `max_uses_per_user` INT DEFAULT 1,
  `valid_from` TIMESTAMP NULL,
  `valid_until` TIMESTAMP NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_coupons_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de pedidos
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `order_number` VARCHAR(20) NOT NULL,
  `user_id` CHAR(36) NULL,
  `customer_email` VARCHAR(255) NOT NULL,
  `customer_name` VARCHAR(255) NOT NULL,
  `customer_phone` VARCHAR(20) NULL,
  `customer_cpf` VARCHAR(14) NULL,
  `shipping_address_id` CHAR(36) NULL,
  `shipping_street` VARCHAR(255) NULL,
  `shipping_number` VARCHAR(20) NULL,
  `shipping_complement` VARCHAR(100) NULL,
  `shipping_neighborhood` VARCHAR(100) NULL,
  `shipping_city` VARCHAR(100) NULL,
  `shipping_state` CHAR(2) NULL,
  `shipping_zip_code` VARCHAR(9) NULL,
  `shipping_recipient` VARCHAR(255) NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  `discount` DECIMAL(10,2) DEFAULT 0,
  `shipping_cost` DECIMAL(10,2) DEFAULT 0,
  `total` DECIMAL(10,2) NOT NULL,
  `coupon_id` CHAR(36) NULL,
  `coupon_code` VARCHAR(50) NULL,
  `status` ENUM('pending', 'awaiting_payment', 'payment_confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') NOT NULL DEFAULT 'pending',
  `payment_method` ENUM('pix', 'credit_card', 'debit_card', 'boleto') NULL,
  `payment_status` ENUM('pending', 'processing', 'approved', 'declined', 'refunded', 'cancelled') DEFAULT 'pending',
  `notes` TEXT NULL,
  `admin_notes` TEXT NULL,
  `tracking_code` VARCHAR(100) NULL,
  `tracking_url` TEXT NULL,
  `shipped_at` TIMESTAMP NULL,
  `delivered_at` TIMESTAMP NULL,
  `cancelled_at` TIMESTAMP NULL,
  `cancellation_reason` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_orders_number` (`order_number`),
  KEY `idx_orders_user` (`user_id`),
  KEY `idx_orders_email` (`customer_email`),
  KEY `idx_orders_status` (`status`),
  KEY `idx_orders_payment_status` (`payment_status`),
  KEY `idx_orders_created` (`created_at`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_orders_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de itens do pedido
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `order_id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `product_name` VARCHAR(255) NOT NULL,
  `product_sku` VARCHAR(50) NOT NULL,
  `product_image` TEXT NULL,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `total_price` DECIMAL(10,2) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_items_order` (`order_id`),
  KEY `idx_order_items_product` (`product_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de pagamentos
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `order_id` CHAR(36) NOT NULL,
  `payment_method` ENUM('pix', 'credit_card', 'debit_card', 'boleto') NOT NULL,
  `status` ENUM('pending', 'processing', 'approved', 'declined', 'refunded', 'cancelled') DEFAULT 'pending',
  `amount` DECIMAL(10,2) NOT NULL,
  `installments` INT DEFAULT 1,
  `external_id` VARCHAR(255) NULL,
  `external_status` VARCHAR(100) NULL,
  `pix_code` TEXT NULL,
  `pix_qr_code` TEXT NULL,
  `pix_expiration` TIMESTAMP NULL,
  `boleto_url` TEXT NULL,
  `boleto_barcode` VARCHAR(100) NULL,
  `boleto_expiration` DATE NULL,
  `card_last_digits` CHAR(4) NULL,
  `card_brand` VARCHAR(50) NULL,
  `paid_at` TIMESTAMP NULL,
  `refunded_at` TIMESTAMP NULL,
  `metadata` JSON NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_payments_order` (`order_id`),
  KEY `idx_payments_status` (`status`),
  KEY `idx_payments_external` (`external_id`),
  CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de histórico de pedidos
DROP TABLE IF EXISTS `order_history`;
CREATE TABLE `order_history` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `order_id` CHAR(36) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `notes` TEXT NULL,
  `created_by` CHAR(36) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_history_order` (`order_id`),
  KEY `idx_order_history_created` (`created_at`),
  CONSTRAINT `fk_order_history_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de aprovações de pedidos
DROP TABLE IF EXISTS `order_approvals`;
CREATE TABLE `order_approvals` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `order_id` CHAR(36) NOT NULL,
  `approved_by` CHAR(36) NOT NULL,
  `action` ENUM('approved', 'rejected') NOT NULL,
  `notes` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_approvals_order` (`order_id`),
  KEY `idx_order_approvals_by` (`approved_by`),
  CONSTRAINT `fk_order_approvals_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_approvals_user` FOREIGN KEY (`approved_by`) REFERENCES `profiles` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de eventos de envio
DROP TABLE IF EXISTS `order_shipping_events`;
CREATE TABLE `order_shipping_events` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `order_id` CHAR(36) NOT NULL,
  `status` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `location` VARCHAR(255) NULL,
  `event_date` TIMESTAMP NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shipping_events_order` (`order_id`),
  KEY `idx_shipping_events_date` (`event_date`),
  CONSTRAINT `fk_shipping_events_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de notas fiscais
DROP TABLE IF EXISTS `order_invoices`;
CREATE TABLE `order_invoices` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `order_id` CHAR(36) NOT NULL,
  `invoice_number` VARCHAR(50) NOT NULL,
  `invoice_series` VARCHAR(10) NULL,
  `invoice_key` VARCHAR(50) NULL,
  `invoice_url` TEXT NULL,
  `issued_at` TIMESTAMP NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_invoices_number` (`invoice_number`),
  KEY `idx_invoices_order` (`order_id`),
  CONSTRAINT `fk_invoices_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de reembolsos
DROP TABLE IF EXISTS `order_refunds`;
CREATE TABLE `order_refunds` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `order_id` CHAR(36) NOT NULL,
  `payment_id` CHAR(36) NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `reason` TEXT NULL,
  `status` ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
  `refunded_by` CHAR(36) NULL,
  `external_id` VARCHAR(255) NULL,
  `refunded_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_refunds_order` (`order_id`),
  KEY `idx_refunds_payment` (`payment_id`),
  CONSTRAINT `fk_refunds_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_refunds_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de configurações da loja
DROP TABLE IF EXISTS `store_settings`;
CREATE TABLE `store_settings` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `setting_key` VARCHAR(100) NOT NULL,
  `setting_value` TEXT NULL,
  `setting_type` ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
  `description` VARCHAR(255) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_store_settings_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de banners
DROP TABLE IF EXISTS `banners`;
CREATE TABLE `banners` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `title` VARCHAR(255) NOT NULL,
  `subtitle` VARCHAR(500) NULL,
  `image_url` TEXT NOT NULL,
  `image_mobile_url` TEXT NULL,
  `link_url` TEXT NULL,
  `button_text` VARCHAR(50) NULL,
  `position` ENUM('hero', 'secondary', 'sidebar') DEFAULT 'hero',
  `sort_order` INT DEFAULT 0,
  `is_active` BOOLEAN DEFAULT TRUE,
  `starts_at` TIMESTAMP NULL,
  `ends_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_banners_active` (`is_active`),
  KEY `idx_banners_position` (`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de FAQs
DROP TABLE IF EXISTS `faqs`;
CREATE TABLE `faqs` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `question` VARCHAR(500) NOT NULL,
  `answer` TEXT NOT NULL,
  `category` VARCHAR(100) NULL,
  `sort_order` INT DEFAULT 0,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_faqs_active` (`is_active`),
  KEY `idx_faqs_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de assinantes da newsletter
DROP TABLE IF EXISTS `newsletter_subscribers`;
CREATE TABLE `newsletter_subscribers` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `email` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `subscribed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `unsubscribed_at` TIMESTAMP NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_newsletter_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- DADOS INICIAIS
-- =============================================

-- Categorias iniciais
INSERT INTO `categories` (`id`, `name`, `slug`, `description`, `sort_order`) VALUES
(UUID(), 'iPhone', 'iphone', 'iPhones seminovos com garantia', 1),
(UUID(), 'iPad', 'ipad', 'iPads seminovos com garantia', 2),
(UUID(), 'Mac', 'mac', 'Macs seminovos com garantia', 3),
(UUID(), 'Apple Watch', 'apple-watch', 'Apple Watch seminovos com garantia', 4),
(UUID(), 'Acessórios', 'acessorios', 'Acessórios Apple originais', 5);

-- Configurações iniciais da loja
INSERT INTO `store_settings` (`setting_key`, `setting_value`, `setting_type`, `description`) VALUES
('store_name', 'iPlace Seminovos', 'string', 'Nome da loja'),
('store_email', 'contato@iplaceseminovos.com.br', 'string', 'Email de contato'),
('store_phone', '0800 123 4567', 'string', 'Telefone de contato'),
('store_whatsapp', '+5598989145930', 'string', 'WhatsApp de contato'),
('free_shipping_threshold', '500', 'number', 'Valor mínimo para frete grátis'),
('default_warranty_months', '12', 'number', 'Meses de garantia padrão'),
('pix_discount_percent', '5', 'number', 'Desconto para pagamento via PIX'),
('max_installments', '12', 'number', 'Número máximo de parcelas'),
('min_installment_value', '100', 'number', 'Valor mínimo da parcela');

-- FAQs iniciais
INSERT INTO `faqs` (`question`, `answer`, `category`, `sort_order`) VALUES
('Os produtos têm garantia?', 'Sim! Todos os nossos produtos seminovos possuem garantia de 12 meses, cobrindo defeitos de fabricação e funcionamento.', 'Garantia', 1),
('Como funciona a garantia?', 'A garantia cobre defeitos de fabricação e funcionamento. Caso seu produto apresente problemas, entre em contato conosco para avaliarmos e realizarmos o reparo ou troca.', 'Garantia', 2),
('Qual a condição dos produtos?', 'Todos os produtos passam por uma rigorosa avaliação técnica e estética. Classificamos em: Excelente (como novo), Muito Bom (mínimos sinais de uso), Bom (sinais de uso visíveis) e Aceitável (sinais de uso mais evidentes).', 'Produtos', 3),
('Posso parcelar minha compra?', 'Sim! Aceitamos pagamento em até 12x no cartão de crédito. Também oferecemos 5% de desconto para pagamentos via PIX.', 'Pagamento', 4),
('Qual o prazo de entrega?', 'O prazo de entrega varia de acordo com sua região. Após a confirmação do pagamento, o produto é enviado em até 2 dias úteis. O prazo total de entrega será informado no checkout.', 'Entrega', 5),
('Posso devolver o produto?', 'Sim! Você tem até 7 dias após o recebimento para solicitar a devolução, conforme o Código de Defesa do Consumidor.', 'Trocas e Devoluções', 6);

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- FIM DO SCHEMA
-- =============================================
