var TKApp = {
    // 获取用户手机号
    getUserPhone: function () {
       return window.prompt("getUserPhone")
    },
    showShare: function(param, callback) {
        var data = {"param": param, "callback": callback}
        window.prompt("showShare", JSON.stringify(data))
    }
}
TKApp.setAMapKey = function(data) {
    window.prompt("setAMapKey", data);
};
