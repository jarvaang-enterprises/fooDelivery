const VerifyUserMiddleware = require('./middlewares/verify.user.middleware');
const AuthorizationController = require('./controllers/auth.controller');
const AuthValidationMiddleware = require('../common/middlewares/auth.validation.middleware');

const VERSION = process.env.API_VERSION

exports.routesConfig = (app) => {
    app.post(VERSION + '/auth', [
        VerifyUserMiddleware.hasAuthValidFields,
        VerifyUserMiddleware.isPasswordAndUserMatch,
        AuthorizationController.login
    ])

    app.post(VERSION + '/auth/refresh', [
        AuthValidationMiddleware.validJWTNeeded,
        AuthValidationMiddleware.verifyRefreshBodyField,
        AuthValidationMiddleware.validRefreshNeeded,
        AuthorizationController.login
    ])

    app.get(VERSION + '/auth/', [
        VerifyUserMiddleware.hasAuthValidFields,
        VerifyUserMiddleware.isPasswordAndUserMatch
    ])
}