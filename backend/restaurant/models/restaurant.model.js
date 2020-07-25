const { Mongoose, mongo } = require("mongoose")

const mongoose = require('../../common/services/mongoose.service').mongoose
const Schema = mongoose.Schema
const restaurantSchema = new Schema({
    restaurantId: String,
    name: String,
    imageUrl: String,
    latitude: Number,
    longitude: Number,
    attributes: Array([
        opensAt,
        closesAt
    ])
});

restaurantSchema.virtual('id').get(function() {
    return this._id.toHexString();
})

restaurantSchema.set('toJSON', {
    virtuals: true
})

const restaurantModel = mongoose.model('Restaurants', restaurantSchema)