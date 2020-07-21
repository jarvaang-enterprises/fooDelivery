// const redis = require('redis')
// const redisClient = redis.createClient()

class TokenBucket {
    constructor(capacity, fillPerHour) {
        this.capacity = capacity
        this.fillPerHour = fillPerHour

        this.lastFilled = Math.floor(Date.now() / (1000 * 60 * 5))

        this.tokens = capacity
    }

    addTokens() {
        if (this.tokens < this.capacity) {
            this.tokens += 1
        }
    }

    take() {

        // Calculate how many tokens (if any) should have been added since the last request
        this.refill()

        if (this.tokens > 0) {
            this.tokens -= 1
            return true
        }

        return false
    }

    refill() {
        const now = Math.floor(Date.now() / (1000 * 60 * 5))
        const rate = (now - this.lastFilled) / this.fillPerHour

        this.tokens = Math.min(this.capacity, this.tokens + Math.floor(rate * this.capacity))
        this.lastFilled = now
    }
}

/** 
 * Request Limiting in API
 * Function responsible for limiting all api requests provided to the app
 * @param per5Minutes
 * @param maxBurst
 * 
 * @returns void
*/
exports.limitRequests = (per5Minutes, maxBurst) => {
    const bucket = new Map();

    return function limitRequestsMiddleware(req, res, next) {
        //     redisClient.exists(req.ip, (err, response) => {
        //         if(err) {
        //             console.log("Problem with redis")
        //             system.exit(0)
        //         }

        //         if (reply === 1) {
        //             redisClient.get(req.ip, (err, redisResponse) => {
        //                 let data = JSON.parse(redisResponse)

        //                 let isFound = false
        //                 data.forEach(bucket => {
        //                     if(bucket.has(req.ip))
        //                 });
        //             })
        //         }
        //     })
        if (!bucket.has(req.ip)) {
            bucket.set(req.ip, new TokenBucket(maxBurst, per5Minutes))
            // redisClient.set(req)
        }

        const bucketForIp = bucket.get(req.ip)
        bucketForIp.take() ? next() : res.status(429).send('Client rate limit exceeded, Please try again in 5 Minutes!')
    }
}