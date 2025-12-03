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
                        callback(false, "Error parsing response")
                    }
                } else {
                    callback(false, "HTTP Error " + xhr.status)
                }
            }
        }
        
        xhr.send(JSON.stringify(data))
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
                        callback(false, "Error parsing response")
                    }
                } else {
                    callback(false, "HTTP Error " + xhr.status)
                }
            }
        }
        
        xhr.send(JSON.stringify(data))
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
