module.exports = {
    "port": process.env.PORT || 5500,
    "JWT_SECRET": "tH!51sA53cUr3p@55w0r6",
    "JWT_EXPIRATION": 120,
    "environment": "dev",
    "permission": {
        "Admin": 2048,
        "User": 1024,
        "Rider": 512
    }
}