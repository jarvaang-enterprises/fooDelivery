const jwt = require('jsonwebtoken'),
secret = process.env.JWT_SECRET,
crypto = require('crypto')

exports.verifyRefreshBodyField = (req, res, next) => {
    if(req.body && req.body.refresh_token) {
        return next()
    } else {
        return res.status(400).send({error: 'Refresh Token Not Found'})
    }
}

exports.validRefreshNeeded = (req, res, next) => {
    let b = new Buffer(req.body.refresh_token, 'base64');
    let refresh_token = b.toString();
    let hash = crypto.createHmac('sha512', req.jwt.refreshKey).update(req.jwt.userId + secret).digest("base64");
    if (hash === refresh_token) {
        req.body = req.jwt;
        return next();
    } else {
        return res.status(400).send({error: 'Invalid refresh token'});
    }
};


exports.validJWTNeeded = (req, res, next) => {
    if (req.headers['x-api-key']) {
        try {
            let authorization = req.headers['x-api-key'];
            if (authorization === null) {
                return res.status(403).send({emsg: 'Authorization failed, Try Logging in again!'})
            } else {
                req.jwt = jwt.verify(authorization, secret);
                return next();
            }

        } catch (err) {
            return res.status(403).send({err: err});
        }
    } else {
        return res.status(401).send();
    }
};
