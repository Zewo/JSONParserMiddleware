// JSONParserMiddleware.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import HTTP
import HTTPMiddleware
import JSON

public struct JSONParserMiddleware: HTTPRequestMiddlewareType {
    public let key = "JSONBody"

    public func respond(request: HTTPRequest) -> HTTPRequestMiddlewareResult {
        var request = request
        guard let mediaType = request.contentType where mediaType.type == "application/json" else {
            return .Next(request)
        }

        guard let JSONBody = try? JSONParser.parse(request.body) else {
            return .Next(request)
        }

        request.context[key] = JSONBody

        return .Next(request)
    }
}

extension HTTPRequest {
    public var JSONBody: JSON? {
        return context["JSONBody"] as? JSON
    }

    public func getJSONBody() throws -> JSON {
        if let JSONBody = JSONBody {
            return JSONBody
        }
        struct Error: ErrorType, CustomStringConvertible {
            let description = "JSON body not found in context. Maybe you forgot to apply the JSONParserMiddleware?"
        }
        throw Error()
    }
}

public let parseJSON = JSONParserMiddleware()