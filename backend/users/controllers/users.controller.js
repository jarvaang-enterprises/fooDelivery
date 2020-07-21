const UserModel = require('../models/users.model')
const crypto = require('crypto')

exports.insert = (req, res) => {
    console.log(req)
    let salt = crypto.randomBytes(32).toString('base64')
    let hash = crypto.createHmac('sha512', salt)
        .update(req.body.passwd)
        .digest('base64')
    // TODO: Have to implement a hash concatenation string and replace the `$` sign
    req.query.passwd = salt + "$" + hash
    req.query.permissionLevel = process.env.PERMISSION_USER
    UserModel.createUser(req.query)
    .then((result) =>{
        res.status(201).send({ res: result})
    })
}

exports.getById = (req, res) => {
    UserModel.findById(req.params.userId).then((result) => {
        if (result == null) res.status(405).send({emsg: 'Specified user doesn\'t exist!'})
        else res.status(200).send(result)
    })
}

exports.patchById = (req, res) => {
    req.body = req.query
    if (req.body.password) {
        let salt = crypto.randomBytes(16).toString('base64');
        let hash = crypto.createHmac('sha512', salt).update(req.body.password).digest("base64");
        req.body.password = salt + "$" + hash;
    }
    UserModel.patchUser(req.params.userId, req.body)
        .then(result => {
            res.status(204).send({})
        })
}

exports.removeById = (req, res) => {
    UserModel.removeById(req.params.userId)
    .then( result => {
        console.log(err)
        res.status(204).send(result)
    }).catch(err=>{
        console.log(err)
        res.status(404).send({errors: 'Specified user does\'nt exist!'})
    })
}

exports.list = (req, res) => {
    
}