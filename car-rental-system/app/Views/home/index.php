<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<!-- Hero Section -->
<div class="hero-section bg-primary text-white py-5 rounded mb-5">
    <div class="container text-center">
        <h1 class="display-4 fw-bold mb-3">
            <i class="fas fa-car"></i> Selamat Datang di Car Rental System
        </h1>
        <p class="lead mb-4">Sewa mobil dengan mudah, aman, dan terpercaya untuk berbagai kebutuhan perjalanan Anda.</p>
        <div class="d-flex justify-content-center gap-3">
            <a href="<?= base_url('cars') ?>" class="btn btn-light btn-lg">
                <i class="fas fa-search"></i> Lihat Mobil
            </a>
            <?php if (!session()->get('logged_in')): ?>
                <a href="<?= base_url('register') ?>" class="btn btn-outline-light btn-lg">
                    <i class="fas fa-user-plus"></i> Daftar Sekarang
                </a>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Features Section -->
<div class="row mb-5">
    <div class="col-md-4 text-center mb-4">
        <div class="feature-card p-4 h-100">
            <i class="fas fa-shield-alt fa-3x text-primary mb-3"></i>
            <h4>Aman & Terpercaya</h4>
            <p>Mobil yang terawat dengan baik dan asuransi lengkap untuk kenyamanan Anda.</p>
        </div>
    </div>
    <div class="col-md-4 text-center mb-4">
        <div class="feature-card p-4 h-100">
            <i class="fas fa-clock fa-3x text-primary mb-3"></i>
            <h4>24/7 Support</h4>
            <p>Layanan customer service yang siap membantu Anda kapan saja dibutuhkan.</p>
        </div>
    </div>
    <div class="col-md-4 text-center mb-4">
        <div class="feature-card p-4 h-100">
            <i class="fas fa-dollar-sign fa-3x text-primary mb-3"></i>
            <h4>Harga Terjangkau</h4>
            <p>Harga sewa yang kompetitif dengan berbagai pilihan mobil sesuai budget.</p>
        </div>
    </div>
</div>

<!-- Featured Cars Section -->
<?php if (!empty($featured_cars)): ?>
<div class="mb-5">
    <h2 class="text-center mb-4">
        <i class="fas fa-star text-warning"></i> Mobil Unggulan
    </h2>
    <div class="row">
        <?php foreach ($featured_cars as $car): ?>
        <div class="col-md-4 mb-4">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h5 class="card-title">
                        <?= $car['brand'] ?> <?= $car['model'] ?>
                    </h5>
                    <p class="card-text text-muted">
                        <i class="fas fa-calendar"></i> <?= $car['year'] ?> | 
                        <i class="fas fa-palette"></i> <?= $car['color'] ?>
                    </p>
                    <p class="card-text"><?= substr($car['description'], 0, 100) ?>...</p>
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="badge bg-success">Tersedia</span>
                        <strong class="text-primary">Rp <?= number_format($car['daily_rate'], 0, ',', '.') ?>/hari</strong>
                    </div>
                </div>
                <div class="card-footer bg-transparent">
                    <div class="d-grid">
                        <a href="<?= base_url('cars/' . $car['id']) ?>" class="btn btn-outline-primary">
                            <i class="fas fa-eye"></i> Lihat Detail
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    </div>
    <div class="text-center">
        <a href="<?= base_url('cars') ?>" class="btn btn-primary btn-lg">
            <i class="fas fa-list"></i> Lihat Semua Mobil
        </a>
    </div>
</div>
<?php endif; ?>

<!-- How It Works Section -->
<div class="bg-light p-5 rounded mb-5">
    <h2 class="text-center mb-4">Cara Kerja</h2>
    <div class="row">
        <div class="col-md-3 text-center mb-4">
            <div class="step-number bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px;">
                <span class="fw-bold">1</span>
            </div>
            <h5>Pilih Mobil</h5>
            <p>Pilih mobil yang sesuai dengan kebutuhan dan budget Anda.</p>
        </div>
        <div class="col-md-3 text-center mb-4">
            <div class="step-number bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px;">
                <span class="fw-bold">2</span>
            </div>
            <h5>Isi Form</h5>
            <p>Isi form pemesanan dengan data yang lengkap dan valid.</p>
        </div>
        <div class="col-md-3 text-center mb-4">
            <div class="step-number bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px;">
                <span class="fw-bold">3</span>
            </div>
            <h5>Konfirmasi</h5>
            <p>Admin akan memproses dan mengkonfirmasi pesanan Anda.</p>
        </div>
        <div class="col-md-3 text-center mb-4">
            <div class="step-number bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px;">
                <span class="fw-bold">4</span>
            </div>
            <h5>Ambil Mobil</h5>
            <p>Ambil mobil sesuai waktu yang telah disepakati.</p>
        </div>
    </div>
</div>

<!-- Contact Section -->
<div class="text-center">
    <h3>Butuh Bantuan?</h3>
    <p class="lead">Tim kami siap membantu Anda dengan berbagai pertanyaan seputar layanan rental mobil.</p>
    <a href="<?= base_url('contact') ?>" class="btn btn-outline-primary btn-lg">
        <i class="fas fa-envelope"></i> Hubungi Kami
    </a>
</div>
<?= $this->endSection() ?>