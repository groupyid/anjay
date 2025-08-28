<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<div class="row justify-content-center">
    <div class="col-md-8 col-lg-6">
        <div class="card shadow">
            <div class="card-header bg-success text-white text-center">
                <h4><i class="fas fa-user-plus"></i> Register</h4>
            </div>
            <div class="card-body">
                <form action="<?= base_url('register') ?>" method="post">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="name" class="form-label">Nama Lengkap</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-user"></i></span>
                                    <input type="text" class="form-control" id="name" name="name" value="<?= old('name') ?>" required>
                                </div>
                                <?php if (isset($validation) && $validation->hasError('name')): ?>
                                    <div class="text-danger small"><?= $validation->getError('name') ?></div>
                                <?php endif; ?>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="email" class="form-label">Email</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                                    <input type="email" class="form-control" id="email" name="email" value="<?= old('email') ?>" required>
                                </div>
                                <?php if (isset($validation) && $validation->hasError('email')): ?>
                                    <div class="text-danger small"><?= $validation->getError('email') ?></div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                    <input type="password" class="form-control" id="password" name="password" required>
                                </div>
                                <?php if (isset($validation) && $validation->hasError('password')): ?>
                                    <div class="text-danger small"><?= $validation->getError('password') ?></div>
                                <?php endif; ?>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="confirm_password" class="form-label">Konfirmasi Password</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                    <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
                                </div>
                                <?php if (isset($validation) && $validation->hasError('confirm_password')): ?>
                                    <div class="text-danger small"><?= $validation->getError('confirm_password') ?></div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="phone" class="form-label">Nomor Telepon</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-phone"></i></span>
                                    <input type="tel" class="form-control" id="phone" name="phone" value="<?= old('phone') ?>" required>
                                </div>
                                <?php if (isset($validation) && $validation->hasError('phone')): ?>
                                    <div class="text-danger small"><?= $validation->getError('phone') ?></div>
                                <?php endif; ?>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="address" class="form-label">Alamat</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-map-marker-alt"></i></span>
                                    <textarea class="form-control" id="address" name="address" rows="1" required><?= old('address') ?></textarea>
                                </div>
                                <?php if (isset($validation) && $validation->hasError('address')): ?>
                                    <div class="text-danger small"><?= $validation->getError('address') ?></div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                    
                    <div class="d-grid">
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-user-plus"></i> Register
                        </button>
                    </div>
                </form>
                
                <hr>
                
                <div class="text-center">
                    <p>Sudah punya akun? <a href="<?= base_url('login') ?>" class="text-decoration-none">Login disini</a></p>
                </div>
            </div>
        </div>
    </div>
</div>
<?= $this->endSection() ?>