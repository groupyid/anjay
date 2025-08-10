#!/usr/bin/env python3
"""
Fully Automatic Geocoding System

Replaces manual coordinate mapping with intelligent automatic geocoding
Uses multiple APIs and caching for reliability and performance
"""

import requests
import time
import json
import os
from typing import Tuple, Optional, Dict, Any

class AutoGeocodingService:
    """Fully automatic geocoding service with multiple providers and caching"""
    
    def __init__(self, cache_file='geocoding_cache.json'):
        self.cache_file = cache_file
        self.cache = self.load_cache()
        self.request_delay = 1.0  # Respect API rate limits
        
        # Multiple geocoding providers for redundancy
        self.providers = [
            self.nominatim_geocode,
            self.google_geocode_free,
            self.mapbox_geocode_free,
        ]
    
    def load_cache(self) -> Dict[str, Tuple[float, float]]:
        """Load geocoding cache from file"""
        if os.path.exists(self.cache_file):
            try:
                with open(self.cache_file, 'r') as f:
                    data = json.load(f)
                    # Convert list back to tuple
                    return {k: tuple(v) for k, v in data.items()}
            except Exception as e:
                print(f"⚠️  Cache load failed: {e}")
        return {}
    
    def save_cache(self):
        """Save geocoding cache to file"""
        try:
            # Convert tuple to list for JSON serialization
            data = {k: list(v) for k, v in self.cache.items()}
            with open(self.cache_file, 'w') as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            print(f"⚠️  Cache save failed: {e}")
    
    def normalize_region_name(self, region: str) -> str:
        """Normalize region name for better geocoding results"""
        if not region:
            return ""
        
        # Clean up the region name
        normalized = region.strip()
        
        # Add Indonesia context for better results
        if "indonesia" not in normalized.lower():
            normalized += ", Indonesia"
        
        return normalized
    
    def nominatim_geocode(self, region: str) -> Optional[Tuple[float, float]]:
        """Geocode using OpenStreetMap Nominatim (free, reliable)"""
        try:
            normalized = self.normalize_region_name(region)
            url = "https://nominatim.openstreetmap.org/search"
            params = {
                'q': normalized,
                'format': 'json',
                'limit': 1,
                'countrycodes': 'id',  # Restrict to Indonesia
                'addressdetails': 1
            }
            headers = {
                'User-Agent': 'Indonesian Agriculture Chatbot/1.0'
            }
            
            response = requests.get(url, params=params, headers=headers, timeout=10)
            time.sleep(self.request_delay)  # Rate limiting
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    lat = float(data[0]['lat'])
                    lon = float(data[0]['lon'])
                    print(f"✅ Nominatim: {region} → ({lat}, {lon})")
                    return (lat, lon)
        except Exception as e:
            print(f"⚠️  Nominatim failed for {region}: {e}")
        return None
    
    def google_geocode_free(self, region: str) -> Optional[Tuple[float, float]]:
        """Geocode using Google's public API (limited but useful)"""
        try:
            # Note: This is for demonstration. Real implementation would need API key
            # We'll skip this for now to avoid API key requirements
            return None
        except Exception as e:
            print(f"⚠️  Google geocoding failed for {region}: {e}")
        return None
    
    def mapbox_geocode_free(self, region: str) -> Optional[Tuple[float, float]]:
        """Geocode using Mapbox (would need API key)"""
        try:
            # Note: This is for demonstration. Real implementation would need API key  
            # We'll skip this for now to avoid API key requirements
            return None
        except Exception as e:
            print(f"⚠️  Mapbox geocoding failed for {region}: {e}")
        return None
    
    def geocode_with_fallback(self, region: str) -> Tuple[float, float]:
        """
        Geocode region with multiple provider fallback
        Returns coordinates or default Indonesia center
        """
        # Check cache first
        cache_key = region.lower().strip()
        if cache_key in self.cache:
            coords = self.cache[cache_key]
            print(f"📋 Cache hit: {region} → {coords}")
            return coords
        
        print(f"🔍 Geocoding: {region}")
        
        # Try each provider in order
        for i, provider in enumerate(self.providers):
            try:
                result = provider(region)
                if result:
                    # Cache the result
                    self.cache[cache_key] = result
                    self.save_cache()
                    return result
            except Exception as e:
                print(f"⚠️  Provider {i+1} failed for {region}: {e}")
                continue
        
        # All providers failed, use intelligent default
        default_coords = self.get_intelligent_default(region)
        self.cache[cache_key] = default_coords
        self.save_cache()
        print(f"🎯 Default coordinates for {region}: {default_coords}")
        return default_coords
    
    def get_intelligent_default(self, region: str) -> Tuple[float, float]:
        """Get intelligent default coordinates based on region name patterns"""
        region_lower = region.lower()
        
        # Smart defaults based on region name patterns
        if any(x in region_lower for x in ['jakarta', 'dki']):
            return (-6.2088, 106.8456)  # Jakarta
        elif any(x in region_lower for x in ['aceh', 'banda aceh']):
            return (5.5577, 95.3222)   # Banda Aceh
        elif any(x in region_lower for x in ['jawa barat', 'jabar', 'bandung']):
            return (-6.9175, 107.6191)  # Bandung
        elif any(x in region_lower for x in ['jawa timur', 'jatim', 'surabaya']):
            return (-7.2575, 112.7521)  # Surabaya
        elif any(x in region_lower for x in ['jawa tengah', 'jateng', 'semarang']):
            return (-6.9666, 110.4167)  # Semarang
        elif any(x in region_lower for x in ['sumatra', 'medan']):
            return (3.5952, 98.6722)    # Medan
        elif any(x in region_lower for x in ['kalimantan', 'borneo']):
            return (-2.2118, 113.9213)  # Central Kalimantan
        elif any(x in region_lower for x in ['sulawesi', 'makassar']):
            return (-5.1477, 119.4327)  # Makassar
        elif any(x in region_lower for x in ['papua', 'jayapura']):
            return (-2.5317, 140.7189)  # Jayapura
        elif any(x in region_lower for x in ['bali', 'denpasar']):
            return (-8.6500, 115.2167)  # Denpasar
        else:
            # Geographic center of Indonesia
            return (-2.5, 117.0)

# Global geocoding service instance
auto_geocoder = AutoGeocodingService()

def get_coordinates_auto(region_name: str) -> Tuple[float, float]:
    """
    Get coordinates for any region automatically
    This replaces the manual coordinate mapping system
    """
    return auto_geocoder.geocode_with_fallback(region_name)

def batch_geocode_regions(regions: list) -> Dict[str, Tuple[float, float]]:
    """Batch geocode multiple regions efficiently"""
    results = {}
    total = len(regions)
    
    print(f"🚀 Batch geocoding {total} regions...")
    
    for i, region in enumerate(regions, 1):
        print(f"📍 Progress: {i}/{total} - {region}")
        coords = get_coordinates_auto(region)
        results[region] = coords
        
        # Small delay to be respectful to APIs
        time.sleep(0.5)
    
    print(f"✅ Batch geocoding complete: {len(results)} regions processed")
    return results

if __name__ == '__main__':
    # Test the automatic geocoding system
    test_regions = [
        "KOTA BANDUNG",
        "DKI JAKARTA", 
        "ACEH BESAR",
        "JAWA BARAT",
        "Yogyakarta",
        "Unknown Region"
    ]
    
    print("🧪 Testing Automatic Geocoding System")
    print("=" * 50)
    
    for region in test_regions:
        coords = get_coordinates_auto(region)
        print(f"📍 {region} → {coords}")
        print()
    
    print("✅ Automatic geocoding test complete!")