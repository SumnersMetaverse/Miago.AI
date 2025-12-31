# mempool.space Compliance and Best Practices

## Overview

This document outlines the compliance requirements and best practices for using mempool.space API services to ensure your account remains in good standing with the network.

## Rate Limits and API Compliance

### Official Rate Limits

**mempool.space Public API:**
- **250 requests per minute per IP address**
- Exceeding this limit will result in HTTP 429 (Too Many Requests) errors
- Repeated violations may result in temporary or permanent IP bans

### Implementation Requirements

To comply with mempool.space rate limits, implement the following in your applications:

1. **Rate Limiting on Client Side**
   ```python
   import time
   from collections import deque
   
   class RateLimiter:
       def __init__(self, max_requests=250, time_window=60):
           self.max_requests = max_requests
           self.time_window = time_window
           self.requests = deque()
       
       def allow_request(self):
           now = time.time()
           # Remove requests older than time window
           while self.requests and self.requests[0] < now - self.time_window:
               self.requests.popleft()
           
           if len(self.requests) < self.max_requests:
               self.requests.append(now)
               return True
           return False
   ```

2. **Error Handling**
   ```python
   def make_api_request(url):
       response = requests.get(url)
       
       if response.status_code == 429:
           # Rate limit exceeded
           retry_after = response.headers.get('Retry-After', 60)
           print(f"Rate limit exceeded. Retry after {retry_after} seconds")
           time.sleep(int(retry_after))
           return make_api_request(url)  # Retry
       
       return response
   ```

3. **Request Batching and Caching**
   - Cache responses to avoid redundant API calls
   - Batch related requests together
   - Use WebSocket connections for real-time data instead of polling
   - Implement local caching with appropriate TTL (Time To Live)

## Best Practices

### 1. Use Self-Hosted Instances for High-Volume Applications

If your application requires more than 250 requests per minute:

- **Set up your own mempool.space instance**
- Connect to your own Bitcoin Core node
- Follow the setup guide in `contrib/mempool-space/README.md`
- This eliminates rate limits and reduces dependency on public services

**Benefits:**
- No rate limits
- Lower latency
- Full control over data
- Better privacy
- No dependency on third-party infrastructure

### 2. Implement Exponential Backoff

When receiving rate limit errors, implement exponential backoff:

```python
import time
import random

def exponential_backoff(attempt, max_delay=300):
    """Calculate delay with exponential backoff and jitter"""
    delay = min(2 ** attempt + random.uniform(0, 1), max_delay)
    return delay

def api_call_with_retry(url, max_attempts=5):
    for attempt in range(max_attempts):
        try:
            response = requests.get(url)
            
            if response.status_code == 429:
                if attempt < max_attempts - 1:
                    delay = exponential_backoff(attempt)
                    print(f"Rate limited. Waiting {delay:.2f} seconds...")
                    time.sleep(delay)
                    continue
                else:
                    raise Exception("Max retry attempts reached")
            
            response.raise_for_status()
            return response
            
        except requests.RequestException as e:
            if attempt < max_attempts - 1:
                delay = exponential_backoff(attempt)
                time.sleep(delay)
            else:
                raise
    
    raise Exception("Request failed after all retry attempts")
```

### 3. Monitor Your API Usage

Implement logging and monitoring to track your API usage:

```python
import logging
from datetime import datetime

class APIUsageMonitor:
    def __init__(self):
        self.request_count = 0
        self.window_start = datetime.now()
        self.rate_limit_hits = 0
        
    def log_request(self):
        self.request_count += 1
        now = datetime.now()
        
        # Reset counter every minute
        if (now - self.window_start).seconds >= 60:
            logging.info(f"API Usage: {self.request_count} requests in last minute")
            if self.request_count > 250:
                logging.warning(f"Exceeded rate limit! {self.request_count} > 250")
            
            self.request_count = 0
            self.window_start = now
    
    def log_rate_limit_hit(self):
        self.rate_limit_hits += 1
        logging.error(f"Rate limit hit! Total hits: {self.rate_limit_hits}")
```

### 4. Use WebSocket Connections

For real-time data, use WebSocket connections instead of polling:

```javascript
// Example WebSocket connection for mempool.space
const ws = new WebSocket('wss://mempool.space/api/v1/ws');

ws.on('message', function(data) {
    const message = JSON.parse(data);
    
    // Handle different message types
    if (message.block) {
        console.log('New block:', message.block);
    }
    
    if (message['mempool-blocks']) {
        console.log('Mempool update:', message['mempool-blocks']);
    }
});

// Subscribe to specific events
ws.send(JSON.stringify({
    action: 'subscribe',
    type: 'blocks'
}));
```

### 5. Optimize Query Patterns

- **Use batch endpoints** when available instead of individual requests
- **Request only necessary data** - use query parameters to filter results
- **Implement pagination** for large datasets
- **Cache static data** (e.g., historical blocks) locally

### 6. Respect Retry-After Headers

Always check and respect the `Retry-After` header in 429 responses:

```python
def handle_rate_limit(response):
    if response.status_code == 429:
        retry_after = response.headers.get('Retry-After')
        
        if retry_after:
            # Header can be in seconds or HTTP date format
            try:
                wait_time = int(retry_after)
            except ValueError:
                # Parse HTTP date format
                from email.utils import parsedate_to_datetime
                retry_date = parsedate_to_datetime(retry_after)
                wait_time = (retry_date - datetime.now()).seconds
            
            print(f"Rate limited. Waiting {wait_time} seconds as instructed")
            time.sleep(wait_time)
        else:
            # Default wait if no header present
            time.sleep(60)
```

## Data Privacy and Security

### 1. API Key Management (If Applicable)

If using private or commercial APIs:

- Store API keys in environment variables, never in code
- Use secure secret management systems (e.g., HashiCorp Vault, AWS Secrets Manager)
- Rotate API keys regularly
- Use different API keys for development, staging, and production

### 2. Data Handling

- **Do not log sensitive transaction data**
- **Implement data retention policies**
- **Encrypt data in transit and at rest**
- **Comply with applicable regulations** (GDPR, CCPA, etc.)

### 3. IP Address Considerations

- Public APIs track rate limits by IP address
- Using proxies or VPNs may share rate limits with other users
- For production applications, use dedicated IP addresses
- Consider IPv6 if available for better address isolation

## Terms of Service Compliance

### Public API Usage

When using mempool.space public API:

1. **Attribution**: Provide attribution to mempool.space when displaying their data
2. **No Abuse**: Do not attempt to circumvent rate limits
3. **Fair Use**: Use the API reasonably and considerately
4. **No Reselling**: Do not resell data obtained from the public API
5. **Caching**: Implement reasonable caching to reduce load

### Commercial Use

For commercial applications:

- Consider sponsoring mempool.space development
- Use self-hosted instances for production workloads
- Contact mempool.space for enterprise API access options
- Ensure proper licensing for any commercial use

## Monitoring and Alerting

### Key Metrics to Track

1. **API Request Rate**: Requests per minute/hour
2. **Rate Limit Hits**: Number of 429 responses received
3. **Error Rate**: Percentage of failed requests
4. **Response Time**: Average API response latency
5. **Cache Hit Rate**: Effectiveness of local caching

### Alert Thresholds

Set up alerts for:

- Request rate approaching 80% of limit (>200 req/min)
- Any rate limit hits (429 responses)
- Error rate above 1%
- Response time above acceptable threshold
- Cache miss rate above 50%

### Example Monitoring Dashboard

```python
class MetricsCollector:
    def __init__(self):
        self.metrics = {
            'requests_per_minute': 0,
            'rate_limit_hits': 0,
            'errors': 0,
            'total_requests': 0,
            'cache_hits': 0,
            'cache_misses': 0
        }
    
    def record_request(self, status_code, from_cache=False):
        self.metrics['total_requests'] += 1
        
        if from_cache:
            self.metrics['cache_hits'] += 1
        else:
            self.metrics['cache_misses'] += 1
            self.metrics['requests_per_minute'] += 1
        
        if status_code == 429:
            self.metrics['rate_limit_hits'] += 1
        elif status_code >= 400:
            self.metrics['errors'] += 1
    
    def get_cache_hit_rate(self):
        total = self.metrics['cache_hits'] + self.metrics['cache_misses']
        if total == 0:
            return 0
        return (self.metrics['cache_hits'] / total) * 100
    
    def should_alert(self):
        alerts = []
        
        if self.metrics['requests_per_minute'] > 200:
            alerts.append("WARNING: Approaching rate limit")
        
        if self.metrics['rate_limit_hits'] > 0:
            alerts.append("CRITICAL: Rate limit hit!")
        
        if self.get_cache_hit_rate() < 50:
            alerts.append("WARNING: Low cache hit rate")
        
        return alerts
```

## Troubleshooting Common Issues

### Issue: Frequent 429 Errors

**Causes:**
- Exceeding 250 requests per minute
- Shared IP with other high-volume users
- Burst traffic patterns

**Solutions:**
1. Implement request rate limiting
2. Add local caching layer
3. Use self-hosted instance
4. Optimize queries to reduce request count
5. Implement request batching

### Issue: Inconsistent Data

**Causes:**
- Mempool volatility
- Different nodes may have different views
- Race conditions in high-frequency updates

**Solutions:**
1. Accept eventual consistency model
2. Implement retry logic for critical data
3. Use confirmations for important transactions
4. Cross-reference with multiple sources

### Issue: High Latency

**Causes:**
- Geographic distance from API servers
- Network congestion
- Server-side rate limiting (soft throttling)

**Solutions:**
1. Use self-hosted instance for lowest latency
2. Implement caching for frequently accessed data
3. Use WebSocket for real-time updates
4. Consider CDN or edge caching for static data

## Testing Compliance

### Rate Limit Testing

Test your rate limiting implementation:

```python
import unittest
import time

class TestRateLimiting(unittest.TestCase):
    def test_rate_limiter_allows_within_limit(self):
        limiter = RateLimiter(max_requests=10, time_window=1)
        
        # Should allow 10 requests
        for _ in range(10):
            self.assertTrue(limiter.allow_request())
        
        # 11th request should be denied
        self.assertFalse(limiter.allow_request())
    
    def test_rate_limiter_resets_after_window(self):
        limiter = RateLimiter(max_requests=5, time_window=1)
        
        # Use up limit
        for _ in range(5):
            limiter.allow_request()
        
        # Should be denied
        self.assertFalse(limiter.allow_request())
        
        # Wait for window to expire
        time.sleep(1.1)
        
        # Should be allowed again
        self.assertTrue(limiter.allow_request())
```

### Integration Testing

Test your application's behavior under rate limiting:

```python
def test_rate_limit_handling():
    """Test that application handles rate limits gracefully"""
    
    # Simulate rate limit response
    mock_response = Mock()
    mock_response.status_code = 429
    mock_response.headers = {'Retry-After': '60'}
    
    # Verify backoff behavior
    start_time = time.time()
    result = handle_rate_limited_request(mock_response)
    elapsed = time.time() - start_time
    
    # Should have waited at least 60 seconds
    assert elapsed >= 60
    assert result is not None
```

## Migration Guide

### Moving from Public API to Self-Hosted

If you're exceeding rate limits, migrate to self-hosted:

1. **Setup Bitcoin Core**
   - Follow `contrib/mempool-space/bitcoin.conf.example`
   - Enable txindex and REST API
   - Wait for initial sync (can take days)

2. **Deploy mempool.space**
   - Clone mempool.space repository
   - Configure backend to use your Bitcoin Core node
   - Setup database (MySQL/MariaDB)
   - Deploy frontend

3. **Update Application**
   - Change API endpoint from `mempool.space` to your instance
   - Remove rate limiting code (optional)
   - Update monitoring for self-hosted metrics

4. **Test Thoroughly**
   - Verify all endpoints work
   - Check data consistency
   - Monitor resource usage
   - Load test your instance

## Resources

- [mempool.space GitHub](https://github.com/mempool/mempool)
- [Bitcoin Core Documentation](https://bitcoin.org/en/bitcoin-core/)
- [Setup Guide](../contrib/mempool-space/README.md)
- [Integration Testing](../contrib/mempool-space/test-integration.py)

## Support

For compliance-related questions:
- mempool.space GitHub Issues: https://github.com/mempool/mempool/issues
- Bitcoin Stack Exchange: https://bitcoin.stackexchange.com/

For rate limit increase requests:
- Contact mempool.space team through their official channels
- Consider sponsorship or enterprise options

## Changelog

### Version 1.0.0 (2025-12-31)
- Initial compliance documentation
- Rate limiting guidelines
- Best practices for API usage
- Migration guide to self-hosted instances
