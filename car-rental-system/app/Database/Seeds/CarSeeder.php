<?php

namespace App\Database\Seeds;

use CodeIgniter\Database\Seeder;

class CarSeeder extends Seeder
{
    public function run()
    {
        $data = [
            [
                'brand' => 'Toyota',
                'model' => 'Avanza',
                'year' => 2020,
                'color' => 'Putih',
                'license_plate' => 'B 1234 ABC',
                'daily_rate' => 300000,
                'description' => 'Mobil keluarga yang nyaman dengan kapasitas 7 penumpang. Cocok untuk perjalanan keluarga atau bisnis.',
                'status' => 'available',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ],
            [
                'brand' => 'Honda',
                'model' => 'Brio',
                'year' => 2021,
                'color' => 'Merah',
                'license_plate' => 'B 5678 DEF',
                'daily_rate' => 250000,
                'description' => 'Mobil city car yang ekonomis dan mudah dikendarai. Ideal untuk perjalanan dalam kota.',
                'status' => 'available',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ],
            [
                'brand' => 'Suzuki',
                'model' => 'Ertiga',
                'year' => 2019,
                'color' => 'Hitam',
                'license_plate' => 'B 9012 GHI',
                'daily_rate' => 280000,
                'description' => 'MPV yang nyaman dengan desain modern. Cocok untuk keluarga dan perjalanan bisnis.',
                'status' => 'available',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ],
            [
                'brand' => 'Daihatsu',
                'model' => 'Xenia',
                'year' => 2020,
                'color' => 'Silver',
                'license_plate' => 'B 3456 JKL',
                'daily_rate' => 270000,
                'description' => 'Mobil keluarga yang praktis dan irit bahan bakar. Ideal untuk penggunaan sehari-hari.',
                'status' => 'available',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ],
            [
                'brand' => 'Mitsubishi',
                'model' => 'Xpander',
                'year' => 2021,
                'color' => 'Biru',
                'license_plate' => 'B 7890 MNO',
                'daily_rate' => 320000,
                'description' => 'MPV premium dengan fitur lengkap dan desain yang elegan. Cocok untuk berbagai kebutuhan.',
                'status' => 'available',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ],
            [
                'brand' => 'Nissan',
                'model' => 'Livina',
                'year' => 2019,
                'color' => 'Abu-abu',
                'license_plate' => 'B 2345 PQR',
                'daily_rate' => 290000,
                'description' => 'Mobil keluarga yang nyaman dengan performa yang handal. Ideal untuk perjalanan jauh.',
                'status' => 'available',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ]
        ];

        $this->db->table('cars')->insertBatch($data);
    }
}