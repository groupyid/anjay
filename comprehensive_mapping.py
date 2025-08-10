#!/usr/bin/env python3
"""
Comprehensive Coordinate Mapping Generator

Creates exhaustive coordinate mapping for all Indonesian regions
including database format variations (KOTA, KABUPATEN prefixes)
"""

def generate_comprehensive_mapping():
    """Generate comprehensive coordinate mapping"""
    
    # Base coordinate map (current)
    base_mapping = {
        # Major Cities
        'Jakarta': (-6.2088, 106.8456),
        'Surabaya': (-7.2575, 112.7521),
        'Bandung': (-6.9175, 107.6191),
        'Medan': (3.5952, 98.6722),
        'Semarang': (-6.9666, 110.4167),
        'Makassar': (-5.1477, 119.4327),
        'Palembang': (-2.9761, 104.7754),
        'Depok': (-6.4025, 106.7942),
        'Tangerang': (-6.1783, 106.6319),
        'Bekasi': (-6.2383, 107.0),
        'Bogor': (-6.5950, 106.8229),
        'Malang': (-7.9666, 112.6326),
        'Yogyakarta': (-7.7956, 110.3695),
        'Denpasar': (-8.6500, 115.2167),
        'Pontianak': (-0.0263, 109.3425),
        'Balikpapan': (-1.2379, 116.8315),
        'Manado': (1.4748, 124.8421),
        'Ambon': (-3.6954, 128.1814),
        'Jayapura': (-2.5317, 140.7189),
        
        # All 34 Provinces
        'Aceh': (4.695135, 96.7493993),
        'Sumatra Utara': (2.1153547, 99.5450974),
        'Sumatra Barat': (-0.7893803, 100.6614298),
        'Riau': (0.2933469, 101.7068294),
        'Jambi': (-1.4851831, 103.6140016),
        'Sumatra Selatan': (-3.3194374, 103.9145314),
        'Bengkulu': (-3.5778471, 102.3463875),
        'Lampung': (-4.5585849, 105.4068079),
        'Kepulauan Bangka Belitung': (-2.7410513, 106.4405872),
        'Kepulauan Riau': (0.9088397, 104.4563299),
        'DKI Jakarta': (-6.2088, 106.8456),
        'Jawa Barat': (-6.9174639, 107.6191228),
        'Jawa Tengah': (-7.150975, 110.1402594),
        'DI Yogyakarta': (-7.7956, 110.3695),
        'Jawa Timur': (-7.5360639, 112.2384017),
        'Banten': (-6.4058172, 106.0640179),
        'Bali': (-8.4095178, 115.188916),
        'Nusa Tenggara Barat': (-8.6529334, 117.3616476),
        'Nusa Tenggara Timur': (-8.6573819, 121.0793705),
        'Kalimantan Barat': (-0.2787808, 111.4752851),
        'Kalimantan Tengah': (-1.6814878, 113.3823545),
        'Kalimantan Selatan': (-3.0926415, 115.2837585),
        'Kalimantan Timur': (1.5726923, 116.4194496),
        'Kalimantan Utara': (2.72074, 117.1683),
        'Sulawesi Utara': (0.6246932, 123.9750018),
        'Sulawesi Tengah': (-1.4300254, 121.4456179),
        'Sulawesi Selatan': (-3.6687994, 119.9740534),
        'Sulawesi Tenggara': (-4.14491, 122.174605),
        'Gorontalo': (0.6999372, 122.4467238),
        'Sulawesi Barat': (-2.8441371, 119.2320784),
        'Maluku': (-3.2384616, 130.1452734),
        'Maluku Utara': (1.5709993, 127.8087693),
        'Papua Barat': (-1.3361154, 133.1747162),
        'Papua': (-4.269928, 138.0803529),
    }
    
    # Generate comprehensive mapping with all variations
    comprehensive_mapping = {}
    
    # Add base mapping
    comprehensive_mapping.update(base_mapping)
    
    # Add database format variations
    for region, coords in base_mapping.items():
        # Original format
        comprehensive_mapping[region] = coords
        
        # Uppercase format
        comprehensive_mapping[region.upper()] = coords
        
        # Add KOTA prefix for cities
        if region in ['Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Semarang', 
                      'Makassar', 'Palembang', 'Depok', 'Tangerang', 'Bekasi', 
                      'Bogor', 'Malang', 'Yogyakarta', 'Denpasar', 'Pontianak', 
                      'Balikpapan', 'Manado', 'Ambon', 'Jayapura']:
            comprehensive_mapping[f'KOTA {region.upper()}'] = coords
            comprehensive_mapping[f'Kota {region}'] = coords
        
        # Add KABUPATEN prefix for regencies
        if region not in ['Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Semarang', 
                          'Makassar', 'Palembang', 'DKI Jakarta']:
            comprehensive_mapping[f'KABUPATEN {region.upper()}'] = coords
            comprehensive_mapping[f'Kabupaten {region}'] = coords
    
    # Add common abbreviations and aliases
    aliases = {
        # Jakarta variations
        'DKI': (-6.2088, 106.8456),
        'DKI JAKARTA': (-6.2088, 106.8456),
        'JAKARTA PUSAT': (-6.1745, 106.8227),
        'JAKARTA UTARA': (-6.1385, 106.8535),
        'JAKARTA SELATAN': (-6.2607, 106.8106),
        'JAKARTA TIMUR': (-6.2146, 106.8786),
        'JAKARTA BARAT': (-6.1783, 106.7549),
        
        # Java abbreviations
        'JABAR': (-6.9174639, 107.6191228),
        'JATENG': (-7.150975, 110.1402594),
        'JATIM': (-7.5360639, 112.2384017),
        'JOGJA': (-7.7956, 110.3695),
        'DIY': (-7.7956, 110.3695),
        
        # Sumatra abbreviations
        'SUMUT': (2.1153547, 99.5450974),
        'SUMBAR': (-0.7893803, 100.6614298),
        'SUMSEL': (-3.3194374, 103.9145314),
        
        # Kalimantan abbreviations
        'KALBAR': (-0.2787808, 111.4752851),
        'KALTENG': (-1.6814878, 113.3823545),
        'KALSEL': (-3.0926415, 115.2837585),
        'KALTIM': (1.5726923, 116.4194496),
        'KALUT': (2.72074, 117.1683),
        
        # Sulawesi abbreviations
        'SULUT': (0.6246932, 123.9750018),
        'SULTENG': (-1.4300254, 121.4456179),
        'SULSEL': (-3.6687994, 119.9740534),
        'SULTRA': (-4.14491, 122.174605),
        'SULBAR': (-2.8441371, 119.2320784),
        
        # Others
        'NTB': (-8.6529334, 117.3616476),
        'NTT': (-8.6573819, 121.0793705),
        'BABEL': (-2.7410513, 106.4405872),
        'KEPRI': (0.9088397, 104.4563299),
    }
    
    comprehensive_mapping.update(aliases)
    
    return comprehensive_mapping

def export_mapping_code():
    """Export the comprehensive mapping as Python code"""
    mapping = generate_comprehensive_mapping()
    
    print("# COMPREHENSIVE COORDINATE MAPPING")
    print("# Generated with all database format variations")
    print(f"# Total entries: {len(mapping)}")
    print()
    print("coordinate_map = {")
    
    # Group by category for better readability
    categories = {
        'Major Cities': [],
        'Database Format (KOTA)': [],
        'Provinces': [],
        'Abbreviations': [],
        'Other Variations': []
    }
    
    for region, coords in sorted(mapping.items()):
        if region.startswith('KOTA '):
            categories['Database Format (KOTA)'].append((region, coords))
        elif region in ['JABAR', 'JATENG', 'JATIM', 'SUMUT', 'SUMBAR', 'KALBAR', 'DKI']:
            categories['Abbreviations'].append((region, coords))
        elif region in ['Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Semarang', 'Makassar']:
            categories['Major Cities'].append((region, coords))
        elif ' ' not in region and region not in ['DKI', 'DIY', 'NTB', 'NTT']:
            categories['Provinces'].append((region, coords))
        else:
            categories['Other Variations'].append((region, coords))
    
    for category, items in categories.items():
        if items:
            print(f"    # {category}")
            for region, coords in items[:10]:  # Show first 10 per category
                print(f"    '{region}': {coords},")
            if len(items) > 10:
                print(f"    # ... and {len(items) - 10} more {category.lower()}")
            print()
    
    print("}")
    print(f"\n# Coverage: {len(mapping)} total coordinate mappings")
    print("# Supports: Cities, Regencies, Provinces, Database formats, Abbreviations")

if __name__ == '__main__':
    export_mapping_code()