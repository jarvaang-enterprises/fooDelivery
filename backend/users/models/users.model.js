const { Mongoose, mongo } = require("mongoose");

const mongoose = require('../../common/services/mongoose.service').mongoose
const Schema = mongoose.Schema
const userSchema = new Schema({
    firstName: String,
    lastName: String,
    email: String,
    password: String,
    // location?: String,
    tmpPassword: String,
    permissionLevel: Number
});

userSchema.virtual('id').get(function(){
    return this._id.toHexString();
})

userSchema.set('toJSON', {
    virtuals: true
})

const userModel = mongoose.model('Users', userSchema)

exports.createUser = (userData) => {
    const user = new userModel(userData)
    return user.save()
}

exports.findById = (id) => {
    try {
        return userModel.findById(id).then(result => {
            if(result == null) return null
            result = result.toJSON()
            delete result._id
            delete result.__v
            delete result.password
            return result
        })
    } catch (_) {
        return null
    }
}

exports.patchUser = (id, userData) => {
    return new Promise((res, rej) => {
        userModel.findById(id, (err, user) => {
            if(err) rej(err)
            for (let i in userData) {
                user[i] = userData[i]
            }
            user.save((err, UpUser) => {
                if(err) return rej(err)
                res(UpUser)
            })
        })
    })
}

// exports.list = (perPage, page) => {
//     return new Promise((res, rej))
// }

exports.removeById = (userId) => {
    return new Promise((resolve, reject) => {
        userModel.remove({ _id: userId}, (result) => {
            if(result) {
                console.log(result)
                reject(result)
                return result
            } else {
                resolve(result)
            }
        })
    })
}

exports.findByEmail = (e) => {
    return userModel.find({ email: email })
}