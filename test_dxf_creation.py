#!/usr/bin/env python3
"""
Simple test script to verify DXF creation functionality.
Run this script to test if DXF files are being created correctly.
"""

import sys
import os
from dxf_creator import DXFCreator

def test_dxf_creation():
    """Test DXF file creation and provide debug information."""
    
    print("🔧 Testing DXF File Creation...")
    print("=" * 50)
    
    try:
        # Initialize DXF Creator
        creator = DXFCreator(output_dir="test_output")
        
        # Test 1: Basic DXF creation
        print("\n📝 Test 1: Creating basic DXF file...")
        basic_file = creator.create_basic_dxf("test_basic.dxf")
        if os.path.exists(basic_file):
            file_size = os.path.getsize(basic_file)
            print(f"✅ SUCCESS: Created {basic_file} ({file_size} bytes)")
        else:
            print(f"❌ FAILED: File not created at {basic_file}")
            return False
        
        # Test 2: Points-based DXF
        print("\n📍 Test 2: Creating DXF from points...")
        test_points = [(0, 0), (25, 0), (25, 25), (0, 25)]
        points_file = creator.create_from_points(test_points, "test_points.dxf")
        if os.path.exists(points_file):
            file_size = os.path.getsize(points_file)
            print(f"✅ SUCCESS: Created {points_file} ({file_size} bytes)")
        else:
            print(f"❌ FAILED: File not created at {points_file}")
            return False
        
        # Test 3: JSON-based DXF
        print("\n📊 Test 3: Creating DXF from JSON data...")
        test_json = {
            "lines": [{"start": {"x": 0, "y": 0}, "end": {"x": 50, "y": 50}}],
            "circles": [{"center": {"x": 25, "y": 25}, "radius": 10}]
        }
        json_file = creator.create_from_json_data(test_json, "test_json.dxf")
        if os.path.exists(json_file):
            file_size = os.path.getsize(json_file)
            print(f"✅ SUCCESS: Created {json_file} ({file_size} bytes)")
        else:
            print(f"❌ FAILED: File not created at {json_file}")
            return False
        
        # Test 4: SolidWorks-style DXF
        print("\n🔧 Test 4: Creating SolidWorks-style DXF...")
        sw_file = creator.create_solidworks_style_drawing("test_solidworks.dxf")
        if os.path.exists(sw_file):
            file_size = os.path.getsize(sw_file)
            print(f"✅ SUCCESS: Created {sw_file} ({file_size} bytes)")
        else:
            print(f"❌ FAILED: File not created at {sw_file}")
            return False
        
        # Validate all files
        print("\n🔍 Validating all created files...")
        all_files = creator.list_created_files()
        valid_count = 0
        for file_path in all_files:
            is_valid = creator.validate_dxf_file(file_path)
            filename = os.path.basename(file_path)
            if is_valid:
                print(f"✅ {filename} - Valid DXF file")
                valid_count += 1
            else:
                print(f"❌ {filename} - Invalid DXF file")
        
        print("\n" + "=" * 50)
        print(f"🎉 SUMMARY: Created {len(all_files)} DXF files, {valid_count} valid")
        
        if valid_count == len(all_files) and len(all_files) > 0:
            print("✅ ALL TESTS PASSED! DXF creation is working correctly.")
            return True
        else:
            print("❌ Some tests failed. Check the error messages above.")
            return False
            
    except ImportError as e:
        print(f"❌ IMPORT ERROR: {e}")
        print("💡 Try installing required packages: pip install ezdxf")
        return False
    except Exception as e:
        print(f"❌ UNEXPECTED ERROR: {e}")
        return False

def check_dependencies():
    """Check if required dependencies are available."""
    print("🔍 Checking dependencies...")
    
    missing_deps = []
    
    try:
        import ezdxf
        print("✅ ezdxf library found")
    except ImportError:
        missing_deps.append("ezdxf")
        print("❌ ezdxf library not found")
    
    if missing_deps:
        print("\n💡 Install missing dependencies with:")
        print(f"   pip install {' '.join(missing_deps)}")
        return False
    
    return True

if __name__ == "__main__":
    print("🚀 DXF Creation Test Suite")
    print("=" * 50)
    
    # Check dependencies first
    if not check_dependencies():
        print("\n❌ Missing dependencies. Please install them before running tests.")
        sys.exit(1)
    
    # Run tests
    if test_dxf_creation():
        print("\n🎉 All tests completed successfully!")
        print("📁 Check the 'test_output' directory for created DXF files.")
        sys.exit(0)
    else:
        print("\n❌ Tests failed. Please check the error messages above.")
        sys.exit(1)