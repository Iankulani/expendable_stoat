"""
Pytest configuration and fixtures for EXPENDABLE_STOAT
"""
import os
import sys
import pytest
import tempfile
import shutil
import sqlite3
from pathlib import Path
from typing import Dict, Any
import json
import time
import threading

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import application modules
from expendable_stoat import (
    ConfigManager, DatabaseManager, CommandHandler,
    SSHManager, TrafficGeneratorEngine, DOSEngine,
    KeyloggerEngine, DeploymentEngine, NetworkTools
)

@pytest.fixture(scope="session")
def temp_dir():
    """Create temporary directory for test data"""
    temp_path = tempfile.mkdtemp()
    yield temp_path
    shutil.rmtree(temp_path)

@pytest.fixture(scope="function")
def test_config(temp_dir):
    """Create test configuration"""
    config = ConfigManager()
    config.config_dir = Path(temp_dir) / ".expendable_stoat"
    config.config_dir.mkdir(exist_ok=True)
    config.config_file = config.config_dir / "config.json"
    config.config = config.DEFAULT_CONFIG.copy()
    config.config['web']['port'] = 5001
    config.config['web']['enabled'] = False
    config.config['keylogger']['enabled'] = False
    config.save()
    return config

@pytest.fixture(scope="function")
def test_db(temp_dir):
    """Create test database"""
    db_path = Path(temp_dir) / "test.db"
    db = DatabaseManager(str(db_path))
    yield db
    db.close()

@pytest.fixture(scope="function")
def test_handler(test_db, test_config):
    """Create test command handler"""
    handler = CommandHandler(test_db)
    return handler

@pytest.fixture(scope="function")
def mock_network_tools(monkeypatch):
    """Mock network tools for testing"""
    class MockNetworkTools:
        @staticmethod
        def ping(target, count=4):
            return type('obj', (object,), {
                'success': True,
                'output': f'PING {target} (127.0.0.1) 56(84) bytes of data.\n64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.1ms',
                'execution_time': 0.1
            })
        
        @staticmethod
        def nmap(target, scan_type="quick"):
            return type('obj', (object,), {
                'success': True,
                'output': f'Starting Nmap 7.80 ( https://nmap.org ) at 2024-01-01 00:00\nNmap scan report for {target}',
                'execution_time': 0.5
            })
        
        @staticmethod
        def location(ip):
            return {'success': True, 'country': 'Test', 'city': 'Test City'}
    
    monkeypatch.setattr('expendable_stoat.NetworkTools', MockNetworkTools)
    return MockNetworkTools

@pytest.fixture(scope="function")
def mock_database(monkeypatch):
    """Mock database for testing"""
    class MockDB:
        def __init__(self):
            self.data = {}
            self.commands = []
            self.threats = []
            self.ips = []
        
        def log_command(self, *args, **kwargs):
            self.commands.append(args)
        
        def log_threat(self, *args, **kwargs):
            self.threats.append(args)
        
        def get_statistics(self):
            return {
                'total_commands': len(self.commands),
                'total_threats': len(self.threats),
                'blocked_ips': 0
            }
        
        def add_managed_ip(self, ip, *args, **kwargs):
            self.ips.append(ip)
            return True
        
        def get_managed_ips(self, *args, **kwargs):
            return [{'ip_address': ip} for ip in self.ips]
        
        def close(self):
            pass
    
    return MockDB()

@pytest.fixture
def sample_command_data():
    """Sample command data for testing"""
    return {
        'command': 'ping 8.8.8.8',
        'source': 'test',
        'success': True,
        'output': 'PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.\n64 bytes from 8.8.8.8: icmp_seq=1 ttl=115 time=10.5 ms',
        'execution_time': 0.1
    }

@pytest.fixture
def sample_threat_data():
    """Sample threat data for testing"""
    return {
        'threat_type': 'port_scan',
        'source_ip': '192.168.1.100',
        'severity': 'medium',
        'description': 'Multiple ports scanned from 192.168.1.100'
    }

@pytest.fixture
def sample_phishing_template():
    """Sample phishing template for testing"""
    return """
    <!DOCTYPE html>
    <html>
    <head><title>Test Login</title></head>
    <body>
        <h1>Test Login Page</h1>
        <form method="POST">
            <input type="text" name="email" placeholder="Email">
            <input type="password" name="password" placeholder="Password">
            <button type="submit">Login</button>
        </form>
    </body>
    </html>
    """

@pytest.fixture(scope="function")
def event_loop():
    """Create event loop for async tests"""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()