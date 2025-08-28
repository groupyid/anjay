<?php

namespace App\Controllers;

use App\Models\UserModel;

class Auth extends BaseController
{
    protected $userModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
    }

    public function index()
    {
        if (session()->get('logged_in')) {
            return redirect()->to(session()->get('role') === 'admin' ? 'admin/dashboard' : 'user/dashboard');
        }
        return view('auth/login');
    }

    public function login()
    {
        $email = $this->request->getPost('email');
        $password = $this->request->getPost('password');

        $user = $this->userModel->where('email', $email)->first();

        if ($user && password_verify($password, $user['password'])) {
            $sessionData = [
                'user_id' => $user['id'],
                'email' => $user['email'],
                'name' => $user['name'],
                'role' => $user['role'],
                'logged_in' => true
            ];
            session()->set($sessionData);

            if ($user['role'] === 'admin') {
                return redirect()->to('admin/dashboard');
            } else {
                return redirect()->to('user/dashboard');
            }
        } else {
            session()->setFlashdata('error', 'Email atau password salah!');
            return redirect()->back();
        }
    }

    public function register()
    {
        if ($this->request->getMethod() === 'get') {
            return view('auth/register');
        }

        $rules = [
            'name' => 'required|min_length[3]',
            'email' => 'required|valid_email|is_unique[users.email]',
            'password' => 'required|min_length[6]',
            'confirm_password' => 'required|matches[password]',
            'phone' => 'required|min_length[10]',
            'address' => 'required|min_length[10]'
        ];

        if (!$this->validate($rules)) {
            return view('auth/register', ['validation' => $this->validator]);
        }

        $data = [
            'name' => $this->request->getPost('name'),
            'email' => $this->request->getPost('email'),
            'password' => password_hash($this->request->getPost('password'), PASSWORD_DEFAULT),
            'phone' => $this->request->getPost('phone'),
            'address' => $this->request->getPost('address'),
            'role' => 'user',
            'created_at' => date('Y-m-d H:i:s')
        ];

        $this->userModel->insert($data);
        session()->setFlashdata('success', 'Registrasi berhasil! Silakan login.');
        return redirect()->to('login');
    }

    public function logout()
    {
        session()->destroy();
        return redirect()->to('login');
    }
}