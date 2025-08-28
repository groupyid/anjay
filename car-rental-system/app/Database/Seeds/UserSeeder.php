<?php

namespace App\Database\Seeds;

use CodeIgniter\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run()
    {
        $data = [
            [
                'name' => 'Administrator',
                'email' => 'admin@carrental.com',
                'password' => password_hash('admin123', PASSWORD_DEFAULT),
                'phone' => '081234567890',
                'address' => 'Jl. Admin No. 1, Jakarta',
                'role' => 'admin',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ],
            [
                'name' => 'John Doe',
                'email' => 'john@example.com',
                'password' => password_hash('user123', PASSWORD_DEFAULT),
                'phone' => '081234567891',
                'address' => 'Jl. User No. 1, Jakarta',
                'role' => 'user',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ],
            [
                'name' => 'Jane Smith',
                'email' => 'jane@example.com',
                'password' => password_hash('user123', PASSWORD_DEFAULT),
                'phone' => '081234567892',
                'address' => 'Jl. User No. 2, Jakarta',
                'role' => 'user',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ]
        ];

        $this->db->table('users')->insertBatch($data);
    }
}