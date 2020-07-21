const e = require("express")

exports.minimumPermissionLevelRequired = (rpl) => {
    return (req, res, next) => {
        let upl = parseInt(req.jwt.permissionLevel)
        let opl = parseInt(req.jwt.otherPermissionLevel)
        if (upl == rpl || opl == rpl) {
            next()
        } else {
            return res.status(403).send("Minimum permission level not met");
        }
    }
}

exports.onlySameUserCanDoThisAction = (req, res, next) => {
    let upl = req.jwt.userId
    if(req.body && req.body.uuid == upl) {
        return next()
    } else {
        return res.status(403).send("Access denied")
    }
}

exports.onlySameUserOrAdminCanDoThisAction = (req, res, next) =>{
    let upl = parseInt(req.jwt.permissionLevel)
    let uId = req.jwt.userId
    if(req.params && req.params.userId == uId) {
        return next()
    } else {
        if(upl === ADMIN_PERMISSION) {
            return next()
        } else {
            return res.status(403).send()
        }
    }
}

exports.sameUserCantDoThisAction = (req, res, next) => {
    let uId = req.jwt.userId
    if(req.params.userId !== uId) {
        return next()
    } else {
        return res.status(400).send()
    }
}