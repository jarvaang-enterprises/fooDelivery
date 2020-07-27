const { Mongoose, mongo } = require("mongoose")

const mongoose = require('../../common/services/mongoose.service').mongoose
const Schema = mongoose.Schema
const restaurantSchema = new Schema({
    restaurantId: String,
    name: String,
    imageUrl: String,
    latitude: Number,
    longitude: Number,
    attributes: Array,
    opensAt: String,
    closesAt: String,
    acceptingOrders: Boolean
});

restaurantSchema.virtual('id').get(function () {
    return this._id.toHexString();
})

restaurantSchema.set('toJSON', {
    virtuals: true
})

const restaurantModel = mongoose.model('restaurants', restaurantSchema)

exports.list = (perPage, page) => {
    return new Promise((resolve, reject) => {
        restaurantModel.find()
            .limit(1000)
            .sort("-acceptingOrders")
            .exec(function (err, restaurants) {
                if (err) reject(err)
                else resolve(restaurants)
            })
    })
}
