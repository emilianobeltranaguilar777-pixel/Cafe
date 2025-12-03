import QtQuick 2.15

QtObject {
    id: root
    
    property string backendUrl: "http://localhost:8000"
    property string token: ""
    
    // GET request
    function get(endpoint, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status >= 200 && xhr.status < 300) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        callback(true, response)
                    } catch(e) {
                        callback(false, "Error parsing response")
                    }
                } else {
                    callback(false, "HTTP Error " + xhr.status)
                }
            }
        }
        
        xhr.send()
    }
    
    // POST request
    function post(endpoint, data, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status >= 200 && xhr.status < 300) {
                    try {
                        var response = xhr.responseText ? JSON.parse(xhr.responseText) : {}
                        callback(true, response)
                    } catch(e) {
                        console.log("Error parsing POST response:", e)
                        callback(false, "Error parsing response: " + e)
                    }
                } else {
                    var errorMsg = "HTTP " + xhr.status
                    try {
                        var errorData = JSON.parse(xhr.responseText)
                        if (errorData.detail) {
                            errorMsg += ": " + errorData.detail
                        }
                    } catch(e) {
                        if (xhr.responseText) {
                            errorMsg += ": " + xhr.responseText
                        }
                    }
                    console.log("POST Error:", errorMsg)
                    callback(false, errorMsg)
                }
            }
        }

        var jsonData = JSON.stringify(data)
        console.log("POST", backendUrl + endpoint, jsonData)
        xhr.send(jsonData)
    }
    
    // PUT request
    function put(endpoint, data, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status >= 200 && xhr.status < 300) {
                    try {
                        var response = xhr.responseText ? JSON.parse(xhr.responseText) : {}
                        callback(true, response)
                    } catch(e) {
                        console.log("Error parsing PUT response:", e)
                        callback(false, "Error parsing response: " + e)
                    }
                } else {
                    var errorMsg = "HTTP " + xhr.status
                    try {
                        var errorData = JSON.parse(xhr.responseText)
                        if (errorData.detail) {
                            errorMsg += ": " + errorData.detail
                        }
                    } catch(e) {
                        if (xhr.responseText) {
                            errorMsg += ": " + xhr.responseText
                        }
                    }
                    console.log("PUT Error:", errorMsg)
                    callback(false, errorMsg)
                }
            }
        }

        var jsonData = JSON.stringify(data)
        console.log("PUT", backendUrl + endpoint, jsonData)
        xhr.send(jsonData)
    }
    
    // DELETE request
    function del(endpoint, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("DELETE", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status >= 200 && xhr.status < 300) {
                    callback(true, "Deleted")
                } else {
                    callback(false, "HTTP Error " + xhr.status)
                }
            }
        }
        
        xhr.send()
    }
}
