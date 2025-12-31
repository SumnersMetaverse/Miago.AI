#!/usr/bin/env python3
"""
Bitcoin Core and mempool.space Integration Test Script

This script helps verify that your Bitcoin Core node is properly configured
for mempool.space integration by testing RPC and REST endpoints.

Usage:
    python3 test-integration.py --user <rpc_username> --password <rpc_password>
    python3 test-integration.py --user mempool --password mypassword --host 127.0.0.1 --port 8332

Options:
    --user          RPC username (required)
    --password      RPC password (required)
    --host          Bitcoin Core RPC host (default: 127.0.0.1)
    --port          Bitcoin Core RPC port (default: 8332)
    --rest-port     Bitcoin Core REST port (default: 8332)
    --verbose       Enable verbose output
"""

import sys
import json
import base64
import argparse
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError


class Colors:
    """ANSI color codes for terminal output"""
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'


def print_header(text):
    """Print a formatted header"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'=' * 70}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text.center(70)}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'=' * 70}{Colors.END}\n")


def print_success(text):
    """Print success message"""
    print(f"{Colors.GREEN}✓ {text}{Colors.END}")


def print_error(text):
    """Print error message"""
    print(f"{Colors.RED}✗ {text}{Colors.END}")


def print_warning(text):
    """Print warning message"""
    print(f"{Colors.YELLOW}⚠ {text}{Colors.END}")


def print_info(text):
    """Print info message"""
    print(f"  {text}")


def test_rpc_connection(host, port, username, password, verbose=False):
    """Test RPC connection to Bitcoin Core"""
    print_header("Testing RPC Connection")
    
    url = f"http://{host}:{port}/"
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Basic {credentials}'
    }
    
    # Test basic RPC connectivity
    payload = json.dumps({
        "jsonrpc": "2.0",
        "id": "test",
        "method": "getblockchaininfo",
        "params": []
    })
    
    try:
        request = Request(url, data=payload.encode(), headers=headers)
        with urlopen(request, timeout=10) as response:
            data = json.loads(response.read().decode())
            
            if 'result' in data:
                print_success("RPC connection successful")
                result = data['result']
                
                print_info(f"Chain: {result.get('chain', 'unknown')}")
                print_info(f"Blocks: {result.get('blocks', 'unknown')}")
                print_info(f"Verification progress: {result.get('verificationprogress', 0) * 100:.2f}%")
                
                if verbose:
                    print_info(f"Headers: {result.get('headers', 'unknown')}")
                    print_info(f"Best block hash: {result.get('bestblockhash', 'unknown')}")
                
                return True, result
            else:
                print_error(f"Unexpected response: {data}")
                return False, None
                
    except HTTPError as e:
        if e.code == 401:
            print_error("Authentication failed - check username and password")
        else:
            print_error(f"HTTP Error {e.code}: {e.reason}")
        return False, None
    except URLError as e:
        print_error(f"Connection failed: {e.reason}")
        print_warning(f"Is Bitcoin Core running on {host}:{port}?")
        return False, None
    except Exception as e:
        print_error(f"Unexpected error: {str(e)}")
        return False, None


def test_rest_api(host, port, verbose=False):
    """Test REST API endpoints"""
    print_header("Testing REST API")
    
    url = f"http://{host}:{port}/rest/chaininfo.json"
    
    try:
        request = Request(url)
        with urlopen(request, timeout=10) as response:
            data = json.loads(response.read().decode())
            
            print_success("REST API is accessible")
            print_info(f"Chain: {data.get('chain', 'unknown')}")
            print_info(f"Blocks: {data.get('blocks', 'unknown')}")
            
            if verbose:
                print_info(f"Best block hash: {data.get('bestblockhash', 'unknown')}")
                print_info(f"Difficulty: {data.get('difficulty', 'unknown')}")
            
            return True, data
            
    except HTTPError as e:
        if e.code == 404:
            print_error("REST API not found - ensure 'rest=1' is set in bitcoin.conf")
        else:
            print_error(f"HTTP Error {e.code}: {e.reason}")
        return False, None
    except URLError as e:
        print_error(f"Connection failed: {e.reason}")
        return False, None
    except Exception as e:
        print_error(f"Unexpected error: {str(e)}")
        return False, None


def test_txindex(host, port, username, password, blockchain_info, verbose=False):
    """Test if transaction index is enabled"""
    print_header("Testing Transaction Index")
    
    url = f"http://{host}:{port}/"
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Basic {credentials}'
    }
    
    # First, try to get index info (Bitcoin Core 0.21.0+)
    payload = json.dumps({
        "jsonrpc": "2.0",
        "id": "test",
        "method": "getindexinfo",
        "params": []
    })
    
    try:
        request = Request(url, data=payload.encode(), headers=headers)
        with urlopen(request, timeout=10) as response:
            data = json.loads(response.read().decode())
            
            if 'result' in data and data['result']:
                if 'txindex' in data['result']:
                    txindex = data['result']['txindex']
                    if txindex.get('synced'):
                        print_success("Transaction index is enabled and synced")
                        print_info(f"Best block height: {txindex.get('best_block_height', 'unknown')}")
                        return True
                    else:
                        print_warning("Transaction index is enabled but still syncing")
                        print_info(f"Current height: {txindex.get('best_block_height', 'unknown')}")
                        return True
                else:
                    print_error("Transaction index is not enabled")
                    print_warning("Add 'txindex=1' to bitcoin.conf and restart with --reindex")
                    return False
            else:
                # Fallback: Try to get a genesis block transaction
                print_info("Using fallback method to check txindex...")
                return test_txindex_fallback(host, port, username, password, verbose)
                
    except Exception as e:
        if verbose:
            print_info(f"getindexinfo failed: {str(e)}")
        print_info("Using fallback method to check txindex...")
        return test_txindex_fallback(host, port, username, password, verbose)


def test_txindex_fallback(host, port, username, password, verbose=False):
    """Fallback method to test txindex by trying to fetch a transaction"""
    url = f"http://{host}:{port}/"
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Basic {credentials}'
    }
    
    # Try to get the coinbase transaction from genesis block
    # This is a well-known transaction that exists in all networks
    payload = json.dumps({
        "jsonrpc": "2.0",
        "id": "test",
        "method": "getblock",
        "params": ["000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f", 1]
    })
    
    try:
        request = Request(url, data=payload.encode(), headers=headers)
        with urlopen(request, timeout=10) as response:
            data = json.loads(response.read().decode())
            
            if 'result' in data and 'tx' in data['result']:
                # If we can get block with tx details, txindex might be enabled
                print_warning("Cannot definitively verify txindex status")
                print_info("Recommendation: Upgrade to Bitcoin Core 0.21.0+ for better index reporting")
                return None
            else:
                print_error("Unable to verify transaction index")
                return None
                
    except Exception as e:
        print_error("Unable to verify transaction index")
        if verbose:
            print_info(f"Error: {str(e)}")
        return None


def test_mempool_access(host, port, username, password, verbose=False):
    """Test mempool access"""
    print_header("Testing Mempool Access")
    
    url = f"http://{host}:{port}/"
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Basic {credentials}'
    }
    
    payload = json.dumps({
        "jsonrpc": "2.0",
        "id": "test",
        "method": "getmempoolinfo",
        "params": []
    })
    
    try:
        request = Request(url, data=payload.encode(), headers=headers)
        with urlopen(request, timeout=10) as response:
            data = json.loads(response.read().decode())
            
            if 'result' in data:
                print_success("Mempool access successful")
                result = data['result']
                
                print_info(f"Transactions in mempool: {result.get('size', 0)}")
                print_info(f"Mempool size: {result.get('bytes', 0) / 1024 / 1024:.2f} MB")
                
                if verbose:
                    print_info(f"Max mempool: {result.get('maxmempool', 0) / 1024 / 1024:.2f} MB")
                    print_info(f"Usage: {result.get('usage', 0) / 1024 / 1024:.2f} MB")
                
                return True
            else:
                print_error("Unexpected response")
                return False
                
    except Exception as e:
        print_error(f"Failed to access mempool: {str(e)}")
        return False


def test_network_info(host, port, username, password, verbose=False):
    """Test network information"""
    print_header("Testing Network Information")
    
    url = f"http://{host}:{port}/"
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Basic {credentials}'
    }
    
    payload = json.dumps({
        "jsonrpc": "2.0",
        "id": "test",
        "method": "getnetworkinfo",
        "params": []
    })
    
    try:
        request = Request(url, data=payload.encode(), headers=headers)
        with urlopen(request, timeout=10) as response:
            data = json.loads(response.read().decode())
            
            if 'result' in data:
                print_success("Network information retrieved")
                result = data['result']
                
                print_info(f"Version: {result.get('version', 'unknown')}")
                print_info(f"Subversion: {result.get('subversion', 'unknown')}")
                print_info(f"Protocol version: {result.get('protocolversion', 'unknown')}")
                print_info(f"Connections: {result.get('connections', 0)}")
                
                if verbose:
                    print_info(f"Network active: {result.get('networkactive', False)}")
                    print_info(f"Local services: {result.get('localservices', 'unknown')}")
                
                return True
            else:
                print_error("Unexpected response")
                return False
                
    except Exception as e:
        print_error(f"Failed to get network info: {str(e)}")
        return False


def print_summary(results):
    """Print test summary"""
    print_header("Test Summary")
    
    passed = sum(1 for r in results.values() if r is True)
    failed = sum(1 for r in results.values() if r is False)
    skipped = sum(1 for r in results.values() if r is None)
    total = len(results)
    
    print_info(f"Total tests: {total}")
    print_success(f"Passed: {passed}")
    if failed > 0:
        print_error(f"Failed: {failed}")
    if skipped > 0:
        print_warning(f"Skipped/Unknown: {skipped}")
    
    print("\n" + "=" * 70)
    
    if failed == 0:
        print(f"\n{Colors.GREEN}{Colors.BOLD}✓ All critical tests passed!{Colors.END}")
        print(f"{Colors.GREEN}Your Bitcoin Core node appears to be properly configured for mempool.space.{Colors.END}\n")
        return 0
    else:
        print(f"\n{Colors.RED}{Colors.BOLD}✗ Some tests failed{Colors.END}")
        print(f"{Colors.RED}Please review the errors above and fix your configuration.{Colors.END}\n")
        return 1


def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description='Test Bitcoin Core integration for mempool.space',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 test-integration.py --user mempool --password mypassword
  python3 test-integration.py --user mempool --password mypassword --host 192.168.1.100 --port 8332 --verbose
        """
    )
    
    parser.add_argument('--user', required=True, help='RPC username')
    parser.add_argument('--password', required=True, help='RPC password')
    parser.add_argument('--host', default='127.0.0.1', help='Bitcoin Core RPC host (default: 127.0.0.1)')
    parser.add_argument('--port', type=int, default=8332, help='Bitcoin Core RPC port (default: 8332)')
    parser.add_argument('--rest-port', type=int, help='Bitcoin Core REST port (default: same as RPC port)')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
    
    args = parser.parse_args()
    
    if args.rest_port is None:
        args.rest_port = args.port
    
    print(f"\n{Colors.BOLD}Bitcoin Core and mempool.space Integration Test{Colors.END}")
    print(f"Testing connection to {args.host}:{args.port}\n")
    
    results = {}
    blockchain_info = None
    
    # Test RPC connection
    success, blockchain_info = test_rpc_connection(args.host, args.port, args.user, args.password, args.verbose)
    results['RPC Connection'] = success
    
    if not success:
        print_error("\nCannot proceed without RPC connection. Please check your configuration.")
        return 1
    
    # Test REST API
    success, _ = test_rest_api(args.host, args.rest_port, args.verbose)
    results['REST API'] = success
    
    # Test transaction index
    success = test_txindex(args.host, args.port, args.user, args.password, blockchain_info, args.verbose)
    results['Transaction Index'] = success
    
    # Test mempool access
    success = test_mempool_access(args.host, args.port, args.user, args.password, args.verbose)
    results['Mempool Access'] = success
    
    # Test network info
    success = test_network_info(args.host, args.port, args.user, args.password, args.verbose)
    results['Network Info'] = success
    
    # Print summary
    return print_summary(results)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}Test interrupted by user{Colors.END}")
        sys.exit(130)
    except Exception as e:
        print(f"\n{Colors.RED}Unexpected error: {str(e)}{Colors.END}")
        sys.exit(1)
