<?php

namespace App\Controllers;

use App\Models\CarModel;

class Home extends BaseController
{
    protected $carModel;

    public function __construct()
    {
        $this->carModel = new CarModel();
    }

    public function index()
    {
        $data['featured_cars'] = $this->carModel->where('status', 'available')->findAll(6);
        return view('home/index', $data);
    }

    public function cars()
    {
        $data['cars'] = $this->carModel->where('status', 'available')->findAll();
        return view('home/cars', $data);
    }

    public function carDetail($id)
    {
        $data['car'] = $this->carModel->find($id);
        if (!$data['car']) {
            return redirect()->to('cars');
        }
        return view('home/car_detail', $data);
    }

    public function about()
    {
        return view('home/about');
    }

    public function contact()
    {
        return view('home/contact');
    }
}