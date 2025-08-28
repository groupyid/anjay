<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<div class="container-fluid">
    <!-- Page Header -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-tachometer-alt"></i> Dashboard Admin
        </h1>
        <div>
            <a href="<?= base_url('admin/cars/create') ?>" class="btn btn-primary">
                <i class="fas fa-plus"></i> Tambah Mobil
            </a>
            <a href="<?= base_url('admin/reports') ?>" class="btn btn-info">
                <i class="fas fa-chart-bar"></i> Laporan
            </a>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="row mb-4">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="dashboard-card">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-uppercase mb-1">Total Mobil</div>
                        <div class="number"><?= $total_cars ?></div>
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-car icon text-primary"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="dashboard-card">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-uppercase mb-1">Total User</div>
                        <div class="number"><?= $total_users ?></div>
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-users icon text-success"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="dashboard-card">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-uppercase mb-1">Total Rental</div>
                        <div class="number"><?= $total_rentals ?></div>
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-key icon text-warning"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="dashboard-card">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-uppercase mb-1">Pending Rental</div>
                        <div class="number"><?= $pending_rentals ?></div>
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-clock icon text-danger"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Rentals -->
    <div class="row">
        <div class="col-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">
                        <i class="fas fa-list"></i> Rental Terbaru
                    </h6>
                    <a href="<?= base_url('admin/rentals') ?>" class="btn btn-sm btn-primary">
                        Lihat Semua
                    </a>
                </div>
                <div class="card-body">
                    <?php if (!empty($recent_rentals)): ?>
                        <div class="table-responsive">
                            <table class="table table-bordered">
                                <thead>
                                    <tr>
                                        <th>User</th>
                                        <th>Mobil</th>
                                        <th>Tanggal</th>
                                        <th>Total</th>
                                        <th>Status</th>
                                        <th>Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($recent_rentals as $rental): ?>
                                    <tr>
                                        <td>
                                            <strong><?= $rental['user_name'] ?></strong><br>
                                            <small class="text-muted"><?= $rental['user_email'] ?></small>
                                        </td>
                                        <td>
                                            <strong><?= $rental['brand'] ?> <?= $rental['model'] ?></strong><br>
                                            <small class="text-muted"><?= $rental['license_plate'] ?></small>
                                        </td>
                                        <td>
                                            <?= date('d/m/Y', strtotime($rental['start_date'])) ?> - 
                                            <?= date('d/m/Y', strtotime($rental['end_date'])) ?>
                                        </td>
                                        <td>
                                            <strong>Rp <?= number_format($rental['total_amount'], 0, ',', '.') ?></strong>
                                        </td>
                                        <td>
                                            <?php
                                            $statusClass = [
                                                'pending' => 'warning',
                                                'approved' => 'success',
                                                'rejected' => 'danger',
                                                'completed' => 'info',
                                                'cancelled' => 'secondary'
                                            ];
                                            $statusText = [
                                                'pending' => 'Menunggu',
                                                'approved' => 'Disetujui',
                                                'rejected' => 'Ditolak',
                                                'completed' => 'Selesai',
                                                'cancelled' => 'Dibatalkan'
                                            ];
                                            ?>
                                            <span class="badge bg-<?= $statusClass[$rental['status']] ?>">
                                                <?= $statusText[$rental['status']] ?>
                                            </span>
                                        </td>
                                        <td>
                                            <?php if ($rental['status'] === 'pending'): ?>
                                                <a href="<?= base_url('admin/rentals/approve/' . $rental['id']) ?>" 
                                                   class="btn btn-sm btn-success" 
                                                   onclick="return confirm('Setujui rental ini?')">
                                                    <i class="fas fa-check"></i>
                                                </a>
                                                <a href="<?= base_url('admin/rentals/reject/' . $rental['id']) ?>" 
                                                   class="btn btn-sm btn-danger" 
                                                   onclick="return confirm('Tolak rental ini?')">
                                                    <i class="fas fa-times"></i>
                                                </a>
                                            <?php endif; ?>
                                        </td>
                                    </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php else: ?>
                        <div class="text-center py-4">
                            <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                            <p class="text-muted">Belum ada rental yang tersedia</p>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="row">
        <div class="col-md-6">
            <div class="card shadow">
                <div class="card-header">
                    <h6 class="m-0 font-weight-bold text-primary">
                        <i class="fas fa-car"></i> Kelola Mobil
                    </h6>
                </div>
                <div class="card-body">
                    <div class="list-group list-group-flush">
                        <a href="<?= base_url('admin/cars') ?>" class="list-group-item list-group-item-action">
                            <i class="fas fa-list text-primary"></i> Lihat Semua Mobil
                        </a>
                        <a href="<?= base_url('admin/cars/create') ?>" class="list-group-item list-group-item-action">
                            <i class="fas fa-plus text-success"></i> Tambah Mobil Baru
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card shadow">
                <div class="card-header">
                    <h6 class="m-0 font-weight-bold text-primary">
                        <i class="fas fa-users"></i> Kelola User
                    </h6>
                </div>
                <div class="card-body">
                    <div class="list-group list-group-flush">
                        <a href="<?= base_url('admin/users') ?>" class="list-group-item list-group-item-action">
                            <i class="fas fa-list text-primary"></i> Lihat Semua User
                        </a>
                        <a href="<?= base_url('admin/rentals') ?>" class="list-group-item list-group-item-action">
                            <i class="fas fa-key text-warning"></i> Kelola Rental
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<?= $this->endSection() ?>