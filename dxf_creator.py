#!/usr/bin/env python3
"""
DXF File Creator - A comprehensive solution for creating and manipulating DXF files.
This script provides functionality to create DXF files from various geometric data,
with proper error handling and debugging capabilities.
"""

import ezdxf
from ezdxf import units
from ezdxf.math import Vec3
import os
import sys
import logging
from typing import List, Tuple, Optional, Dict, Any
import json

# Set up logging for debugging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('dxf_creation.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class DXFCreator:
    """
    A comprehensive DXF file creator with various geometric primitives and utilities.
    """
    
    def __init__(self, output_dir: str = "output"):
        """
        Initialize the DXF Creator.
        
        Args:
            output_dir (str): Directory to save DXF files
        """
        self.output_dir = output_dir
        self.ensure_output_directory()
        logger.info(f"DXF Creator initialized with output directory: {self.output_dir}")
    
    def ensure_output_directory(self):
        """Ensure the output directory exists."""
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
            logger.info(f"Created output directory: {self.output_dir}")
    
    def create_basic_dxf(self, filename: str = "basic_drawing.dxf") -> str:
        """
        Create a basic DXF file with some simple geometric entities.
        
        Args:
            filename (str): Name of the DXF file to create
            
        Returns:
            str: Full path to the created file
        """
        try:
            # Create a new DXF document
            doc = ezdxf.new('R2010')  # AutoCAD 2010 format
            doc.units = units.MM  # Set units to millimeters
            
            # Get the modelspace
            msp = doc.modelspace()
            
            # Add some basic entities
            logger.info("Adding basic geometric entities...")
            
            # Add a line
            msp.add_line((0, 0), (100, 100))
            
            # Add a circle
            msp.add_circle((50, 50), radius=25)
            
            # Add a rectangle
            msp.add_lwpolyline([(20, 20), (80, 20), (80, 60), (20, 60), (20, 20)])
            
            # Add an arc
            msp.add_arc((75, 75), radius=15, start_angle=0, end_angle=90)
            
            # Add text
            msp.add_text("DXF Creation Test", dxfattribs={'height': 5, 'insert': (10, 10)})
            
            # Save the DXF file
            filepath = os.path.join(self.output_dir, filename)
            doc.saveas(filepath)
            logger.info(f"Basic DXF file created successfully: {filepath}")
            
            return filepath
            
        except Exception as e:
            logger.error(f"Error creating basic DXF file: {str(e)}")
            raise
    
    def create_from_points(self, points: List[Tuple[float, float]], 
                          filename: str = "points_drawing.dxf",
                          connect_points: bool = True) -> str:
        """
        Create a DXF file from a list of 2D points.
        
        Args:
            points (List[Tuple[float, float]]): List of (x, y) coordinates
            filename (str): Name of the DXF file to create
            connect_points (bool): Whether to connect points with lines
            
        Returns:
            str: Full path to the created file
        """
        try:
            if not points:
                raise ValueError("No points provided")
            
            logger.info(f"Creating DXF from {len(points)} points...")
            
            # Create a new DXF document
            doc = ezdxf.new('R2010')
            doc.units = units.MM
            msp = doc.modelspace()
            
            # Add points as small circles
            for i, (x, y) in enumerate(points):
                msp.add_circle((x, y), radius=1)
                msp.add_text(f"P{i+1}", dxfattribs={'height': 2, 'insert': (x+2, y+2)})
            
            # Connect points with lines if requested
            if connect_points and len(points) > 1:
                for i in range(len(points) - 1):
                    msp.add_line(points[i], points[i + 1])
                
                # Close the shape if more than 2 points
                if len(points) > 2:
                    msp.add_line(points[-1], points[0])
            
            # Save the file
            filepath = os.path.join(self.output_dir, filename)
            doc.saveas(filepath)
            logger.info(f"Points DXF file created successfully: {filepath}")
            
            return filepath
            
        except Exception as e:
            logger.error(f"Error creating DXF from points: {str(e)}")
            raise
    
    def create_from_json_data(self, json_data: Dict[str, Any], 
                             filename: str = "json_drawing.dxf") -> str:
        """
        Create a DXF file from JSON data containing geometric information.
        
        Args:
            json_data (Dict[str, Any]): JSON data with geometric entities
            filename (str): Name of the DXF file to create
            
        Returns:
            str: Full path to the created file
        """
        try:
            logger.info("Creating DXF from JSON data...")
            
            # Create a new DXF document
            doc = ezdxf.new('R2010')
            doc.units = units.MM
            msp = doc.modelspace()
            
            # Process different types of entities
            if 'lines' in json_data:
                for line in json_data['lines']:
                    start = (line['start']['x'], line['start']['y'])
                    end = (line['end']['x'], line['end']['y'])
                    msp.add_line(start, end)
            
            if 'circles' in json_data:
                for circle in json_data['circles']:
                    center = (circle['center']['x'], circle['center']['y'])
                    radius = circle['radius']
                    msp.add_circle(center, radius)
            
            if 'rectangles' in json_data:
                for rect in json_data['rectangles']:
                    x, y = rect['x'], rect['y']
                    width, height = rect['width'], rect['height']
                    points = [(x, y), (x + width, y), (x + width, y + height), (x, y + height), (x, y)]
                    msp.add_lwpolyline(points)
            
            if 'points' in json_data:
                for point in json_data['points']:
                    x, y = point['x'], point['y']
                    msp.add_circle((x, y), radius=0.5)
            
            # Save the file
            filepath = os.path.join(self.output_dir, filename)
            doc.saveas(filepath)
            logger.info(f"JSON DXF file created successfully: {filepath}")
            
            return filepath
            
        except Exception as e:
            logger.error(f"Error creating DXF from JSON: {str(e)}")
            raise
    
    def create_solidworks_style_drawing(self, filename: str = "solidworks_style.dxf") -> str:
        """
        Create a DXF file that mimics typical SolidWorks drawing outputs.
        
        Args:
            filename (str): Name of the DXF file to create
            
        Returns:
            str: Full path to the created file
        """
        try:
            logger.info("Creating SolidWorks-style DXF drawing...")
            
            # Create a new DXF document
            doc = ezdxf.new('R2010')
            doc.units = units.MM
            msp = doc.modelspace()
            
            # Create a typical mechanical part outline
            # Main body rectangle
            main_body = [(0, 0), (100, 0), (100, 50), (0, 50), (0, 0)]
            msp.add_lwpolyline(main_body)
            
            # Add mounting holes
            hole_positions = [(15, 15), (85, 15), (85, 35), (15, 35)]
            for x, y in hole_positions:
                msp.add_circle((x, y), radius=3)  # M6 holes
            
            # Add a center feature
            msp.add_circle((50, 25), radius=8)
            
            # Add dimensions (as text for simplicity)
            msp.add_text("100", dxfattribs={'height': 3, 'insert': (50, -8)})
            msp.add_text("50", dxfattribs={'height': 3, 'rotation': 90, 'insert': (-8, 25)})
            
            # Add centerlines
            msp.add_line((50, -5), (50, 55), dxfattribs={'linetype': 'CENTER'})
            msp.add_line((-5, 25), (105, 25), dxfattribs={'linetype': 'CENTER'})
            
            # Add a title block
            title_block = [(120, 0), (200, 0), (200, 30), (120, 30), (120, 0)]
            msp.add_lwpolyline(title_block)
            msp.add_text("Part Name: Sample Part", dxfattribs={'height': 2.5, 'insert': (125, 25)})
            msp.add_text("Drawing No: SW-001", dxfattribs={'height': 2.5, 'insert': (125, 20)})
            msp.add_text("Scale: 1:1", dxfattribs={'height': 2.5, 'insert': (125, 15)})
            msp.add_text("Material: Steel", dxfattribs={'height': 2.5, 'insert': (125, 10)})
            msp.add_text("Units: mm", dxfattribs={'height': 2.5, 'insert': (125, 5)})
            
            # Save the file
            filepath = os.path.join(self.output_dir, filename)
            doc.saveas(filepath)
            logger.info(f"SolidWorks-style DXF file created successfully: {filepath}")
            
            return filepath
            
        except Exception as e:
            logger.error(f"Error creating SolidWorks-style DXF: {str(e)}")
            raise
    
    def validate_dxf_file(self, filepath: str) -> bool:
        """
        Validate that a DXF file was created correctly and can be read.
        
        Args:
            filepath (str): Path to the DXF file to validate
            
        Returns:
            bool: True if file is valid, False otherwise
        """
        try:
            if not os.path.exists(filepath):
                logger.error(f"DXF file does not exist: {filepath}")
                return False
            
            # Try to read the file
            doc = ezdxf.readfile(filepath)
            msp = doc.modelspace()
            
            # Count entities
            entity_count = len(list(msp))
            logger.info(f"DXF file validation successful: {filepath}")
            logger.info(f"File contains {entity_count} entities")
            
            return True
            
        except Exception as e:
            logger.error(f"DXF file validation failed: {str(e)}")
            return False
    
    def list_created_files(self) -> List[str]:
        """
        List all DXF files in the output directory.
        
        Returns:
            List[str]: List of DXF file paths
        """
        try:
            dxf_files = []
            for file in os.listdir(self.output_dir):
                if file.lower().endswith('.dxf'):
                    dxf_files.append(os.path.join(self.output_dir, file))
            
            logger.info(f"Found {len(dxf_files)} DXF files in output directory")
            return dxf_files
            
        except Exception as e:
            logger.error(f"Error listing DXF files: {str(e)}")
            return []

def main():
    """
    Main function to demonstrate DXF creation capabilities.
    """
    print("=== DXF File Creation Demo ===")
    
    try:
        # Initialize the DXF Creator
        creator = DXFCreator()
        
        # Create various types of DXF files
        print("\n1. Creating basic DXF file...")
        basic_file = creator.create_basic_dxf()
        print(f"Created: {basic_file}")
        
        print("\n2. Creating DXF from points...")
        sample_points = [(0, 0), (50, 0), (50, 30), (25, 50), (0, 30)]
        points_file = creator.create_from_points(sample_points)
        print(f"Created: {points_file}")
        
        print("\n3. Creating DXF from JSON data...")
        sample_json = {
            "lines": [
                {"start": {"x": 10, "y": 10}, "end": {"x": 90, "y": 10}},
                {"start": {"x": 90, "y": 10}, "end": {"x": 90, "y": 40}}
            ],
            "circles": [
                {"center": {"x": 30, "y": 30}, "radius": 10}
            ],
            "rectangles": [
                {"x": 60, "y": 20, "width": 20, "height": 15}
            ]
        }
        json_file = creator.create_from_json_data(sample_json)
        print(f"Created: {json_file}")
        
        print("\n4. Creating SolidWorks-style DXF...")
        sw_file = creator.create_solidworks_style_drawing()
        print(f"Created: {sw_file}")
        
        # Validate all created files
        print("\n5. Validating created files...")
        all_files = creator.list_created_files()
        for file in all_files:
            is_valid = creator.validate_dxf_file(file)
            status = "✓ Valid" if is_valid else "✗ Invalid"
            print(f"{status}: {os.path.basename(file)}")
        
        print(f"\n=== Success! Created {len(all_files)} DXF files ===")
        print(f"Output directory: {creator.output_dir}")
        
    except Exception as e:
        logger.error(f"Error in main execution: {str(e)}")
        print(f"Error: {str(e)}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())