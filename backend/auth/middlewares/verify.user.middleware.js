const UserModel = require('../../users/models/users.model')
const crypto = require('crypto')

exports.hasAuthValidFields = (req, res, next) => {
    let errors = Array()
    if (req.query) {
        !req.query.email ? errors.push('Missing email field!') : null
        !req.query.password ? errors.push('Missing password field!') : null
        return errors.length ? res.status(400).send({ emsg: errors.join('|') }) :
            next()
    } else {
        return res.status(400).send({emsg: 'Please fill in all fields!'})
    }
}

exports.isPasswordAndUserMatch = (req, res, next) => {
    req.body = req.query
    UserModel.findByEmail(req.body.email)
    .then( user => {
        if(!user[0]){
            res.status(404).send({errors: ['Incorrect credentials']})
        } else {
            // TODO: Update `$` with created hash concatenator
            let passwordFields = user[0].password.split('$')
            let salt = passwordFields[0]
            let hash = crypto.createHmac('sha512', salt).update(req.body.password).digest('base64')
            if(hash === passwordFields[1]) {
                req.body = {
                    userData: user[0]
                }
                return next()
            } else {
                return res.status(400).send({errors: ['Invalid password']})
            }
        }
    })
}