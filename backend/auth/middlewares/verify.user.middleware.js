const UserModel = require('../../users/models/users.model')
const crypto = require('crypto')

exports.hasAuthValidFields = (req, res, next) => {
    let errors = Array()
    if (req.body) {
        !req.body.email ? errors.push('Missing email field!') : null
        !req.body.passwd ? errors.push('Missing password field!') : null
        return errors.length ? res.status(400).send({ emsg: errors.join('|') }) :
            next()
    } else {
        return res.status(400).send({emsg: 'Please fill in all fields!'})
    }
}

exports.isPasswordAndUserMatch = (req, res, next) => {
    // req.body = req.query
    UserModel.findByEmail(req.body.email)
    .then( user => {
        if(!user[0]){
            res.status(404).send({errors: ['Incorrect credentials']})
        } else {
            let concat = Buffer.from(process.env.HASH_CONCAT, 'utf-8').toString('base64')
            let passwordFields = user[0].passwd.split(concat)
            let salt = passwordFields[0]
            let hash = crypto.createHmac('sha512', salt).update(req.body.passwd).digest('base64')
            if(hash === passwordFields[1]) {
                req.body = {
                    userId: user[0]._id,
                    email: user[0].email,
                    permissionLevel: user[0].permissionLevel,
                    otherPermissionLevel: user[0].otherPermissionLevel,
                    provider: 'email',
                    firstName: user[0].firstName,
                    lastName: user[0].lastName
                }
                return next()
            } else {
                return res.status(400).send({errors: ['Invalid password']})
            }
        }
    })
}