import QtQuick 2.15

QtObject {
    id: root
    
    property string backendUrl: "http://localhost:8000"
    property string token: ""
    
    function handleResponse(xhr, callback) {
        if (xhr.readyState !== XMLHttpRequest.DONE)
            return

        if (xhr.status >= 200 && xhr.status < 300) {
            try {
                var response = xhr.responseText ? JSON.parse(xhr.responseText) : {}
                callback(true, response)
            } catch(e) {
                console.log("Response parse error", e, xhr.responseText)
                callback(false, "Error parsing response")
            }
        } else {
            var errorMsg = "HTTP " + xhr.status
            try {
                var errorData = JSON.parse(xhr.responseText)
                if (errorData.detail)
                    errorMsg += ": " + errorData.detail
            } catch(e) {
                if (xhr.responseText)
                    errorMsg += ": " + xhr.responseText
            }
            console.log("Request error", xhr.status, xhr.responseText)
            callback(false, errorMsg)
        }
    }

    // GET request
    function get(endpoint, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)

        xhr.onreadystatechange = function() { handleResponse(xhr, callback) }

        xhr.send()
    }

    // POST request
    function post(endpoint, data, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() { handleResponse(xhr, callback) }

        xhr.send(JSON.stringify(data))
    }

    // PUT request
    function put(endpoint, data, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() { handleResponse(xhr, callback) }

        xhr.send(JSON.stringify(data))
    }

    // PATCH request
    function patch(endpoint, data, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("PATCH", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() { handleResponse(xhr, callback) }

        xhr.send(JSON.stringify(data))
    }

    // DELETE request
    function del(endpoint, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("DELETE", backendUrl + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)

        xhr.onreadystatechange = function() { handleResponse(xhr, callback) }

        xhr.send()
    }
}
