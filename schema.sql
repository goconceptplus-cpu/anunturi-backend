-- schema.sql (idempotent)
CREATE TABLE IF NOT EXISTS counties (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    parent_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    county_id INTEGER REFERENCES counties(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS announcements (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    county_id INTEGER NOT NULL REFERENCES counties(id) ON DELETE RESTRICT,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'RON',
    contact_name VARCHAR(100),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days')
);
CREATE TABLE IF NOT EXISTS announcement_images (
    id SERIAL PRIMARY KEY,
    announcement_id INTEGER NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    file_path VARCHAR(500) NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    is_primary BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_announcements_user_id ON announcements(user_id);
CREATE INDEX IF NOT EXISTS idx_announcements_category_id ON announcements(category_id);
CREATE INDEX IF NOT EXISTS idx_announcements_county_id ON announcements(county_id);
CREATE INDEX IF NOT EXISTS idx_announcements_is_active ON announcements(is_active);
CREATE INDEX IF NOT EXISTS idx_announcements_created_at ON announcements(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_announcements_price ON announcements(price);
CREATE INDEX IF NOT EXISTS idx_announcement_images_announcement_id ON announcement_images(announcement_id);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_announcements_updated_at ON announcements;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

INSERT INTO counties (name, code) VALUES 
('Alba', 'AB'), ('Arad', 'AR'), ('Argeș', 'AG'), ('Bacău', 'BC'),
('Bihor', 'BH'), ('Bistrița-Năsăud', 'BN'), ('Botoșani', 'BT'), ('Brașov', 'BV'),
('Brăila', 'BR'), ('Buzău', 'BZ'), ('Caraș-Severin', 'CS'), ('Călărași', 'CL'),
('Cluj', 'CJ'), ('Constanța', 'CT'), ('Covasna', 'CV'), ('Dâmbovița', 'DB'),
('Dolj', 'DJ'), ('Galați', 'GL'), ('Giurgiu', 'GR'), ('Gorj', 'GJ'),
('Harghita', 'HR'), ('Hunedoara', 'HD'), ('Ialomița', 'IL'), ('Iași', 'IS'),
('Ilfov', 'IF'), ('Maramureș', 'MM'), ('Mehedinți', 'MH'), ('Mureș', 'MS'),
('Neamț', 'NT'), ('Olt', 'OT'), ('Prahova', 'PH'), ('Satu Mare', 'SM'),
('Sălaj', 'SJ'), ('Sibiu', 'SB'), ('Suceava', 'SV'), ('Teleorman', 'TR'),
('Timiș', 'TM'), ('Tulcea', 'TL'), ('Vaslui', 'VS'), ('Vâlcea', 'VL'),
('Vrancea', 'VN'), ('București', 'B')
ON CONFLICT DO NOTHING;

INSERT INTO categories (name, slug, parent_id, icon) VALUES 
('Imobiliare', 'imobiliare', NULL, 'home'),
('Auto', 'auto', NULL, 'car'),
('Electronice', 'electronice', NULL, 'tv'),
('Moda', 'moda', NULL, 'shirt'),
('Casa & Grădina', 'casa-gradina', NULL, 'hammer'),
('Sport & Hobby', 'sport-hobby', NULL, 'football'),
('Servicii', 'servicii', NULL, 'briefcase'),
('Locuri de muncă', 'locuri-munca', NULL, 'users')
ON CONFLICT DO NOTHING;

INSERT INTO categories (name, slug, parent_id) VALUES 
('Apartamente de vânzare', 'apartamente-vanzare', 1),
('Case de vânzare', 'case-vanzare', 1),
('Apartamente de închiriat', 'apartamente-inchiriat', 1),
('Case de închiriat', 'case-inchiriat', 1),
('Autoturisme', 'autoturisme', 2),
('Motociclete', 'motociclete', 2),
('Camioane', 'camioane', 2),
('Piese auto', 'piese-auto', 2)
ON CONFLICT DO NOTHING;
