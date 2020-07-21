const mongoose = require('mongoose')
let count = 0

const options = {
    autoIndex: false,
    poolSize: 10,
    bufferMaxEntries: 0,
    useNewUrlParser: true,
    useUnifiedTopology: true
}

const connectWithRetry = _ => {
    mongoose.connect(process.env.ENV == 'dev' ? process.env.DATABASE_LOCAL : process.env.DATABASE, options)
        .then(_ => {
            console.log('Database connection successful')
        }).catch(e => {
            console.log('Database connection failed, retrying ', ++count)
            setTimeout(connectWithRetry, 5000)
        })
}

connectWithRetry()
exports.mongoose = mongoose