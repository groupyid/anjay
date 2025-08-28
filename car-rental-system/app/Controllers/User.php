<?php

namespace App\Controllers;

use App\Models\CarModel;
use App\Models\RentalModel;
use App\Models\UserModel;

class User extends BaseController
{
    protected $carModel;
    protected $rentalModel;
    protected $userModel;

    public function __construct()
    {
        $this->carModel = new CarModel();
        $this->rentalModel = new RentalModel();
        $this->userModel = new UserModel();
    }

    public function dashboard()
    {
        $userId = session()->get('user_id');
        $data = [
            'my_rentals' => $this->rentalModel->where('user_id', $userId)->findAll(),
            'available_cars' => $this->carModel->where('status', 'available')->findAll(6)
        ];
        return view('user/dashboard', $data);
    }

    public function cars()
    {
        $data['cars'] = $this->carModel->where('status', 'available')->findAll();
        return view('user/cars', $data);
    }

    public function carDetail($id)
    {
        $data['car'] = $this->carModel->find($id);
        if (!$data['car']) {
            return redirect()->to('user/cars');
        }
        return view('user/car_detail', $data);
    }

    public function rentCar()
    {
        $rules = [
            'car_id' => 'required|numeric',
            'start_date' => 'required|valid_date',
            'end_date' => 'required|valid_date',
            'total_days' => 'required|numeric|greater_than[0]'
        ];

        if (!$this->validate($rules)) {
            session()->setFlashdata('error', 'Data tidak valid!');
            return redirect()->back();
        }

        $carId = $this->request->getPost('car_id');
        $startDate = $this->request->getPost('start_date');
        $endDate = $this->request->getPost('end_date');
        $totalDays = $this->request->getPost('total_days');

        // Check if car is available
        $car = $this->carModel->find($carId);
        if (!$car || $car['status'] !== 'available') {
            session()->setFlashdata('error', 'Mobil tidak tersedia!');
            return redirect()->back();
        }

        // Check if dates are valid
        if (strtotime($startDate) < time() || strtotime($endDate) <= strtotime($startDate)) {
            session()->setFlashdata('error', 'Tanggal tidak valid!');
            return redirect()->back();
        }

        $data = [
            'user_id' => session()->get('user_id'),
            'car_id' => $carId,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'total_days' => $totalDays,
            'total_amount' => $car['daily_rate'] * $totalDays,
            'status' => 'pending',
            'created_at' => date('Y-m-d H:i:s')
        ];

        $this->rentalModel->insert($data);
        
        // Update car status to rented
        $this->carModel->update($carId, ['status' => 'rented']);

        session()->setFlashdata('success', 'Permintaan rental berhasil dikirim! Menunggu persetujuan admin.');
        return redirect()->to('user/my-rentals');
    }

    public function myRentals()
    {
        $userId = session()->get('user_id');
        $data['rentals'] = $this->rentalModel->getUserRentalsWithDetails($userId);
        return view('user/my_rentals', $data);
    }

    public function profile()
    {
        if ($this->request->getMethod() === 'get') {
            $userId = session()->get('user_id');
            $data['user'] = $this->userModel->find($userId);
            return view('user/profile', $data);
        }

        $userId = session()->get('user_id');
        $rules = [
            'name' => 'required|min_length[3]',
            'phone' => 'required|min_length[10]',
            'address' => 'required|min_length[10]'
        ];

        if (!$this->validate($rules)) {
            $data['user'] = $this->userModel->find($userId);
            return view('user/profile', ['validation' => $this->validator, 'user' => $data['user']]);
        }

        $data = [
            'name' => $this->request->getPost('name'),
            'phone' => $this->request->getPost('phone'),
            'address' => $this->request->getPost('address'),
            'updated_at' => date('Y-m-d H:i:s')
        ];

        $this->userModel->update($userId, $data);
        session()->setFlashdata('success', 'Profil berhasil diupdate!');
        return redirect()->to('user/profile');
    }
}