//
//  MovieClientHandler.swift
//  MovieClient
//
//  Created by Jonathan Wong on 5/16/18.
//

import Foundation
import NIO

class MovieClientHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    private var numBytes = 0
    
    func channelActive(ctx: ChannelHandlerContext) {
        // create a movie
        var movie = Movie()
        movie.genre = .action
        movie.title = "Avengers: Infinity War"
        movie.year = 2018
        
        do {
            // serialize the data
            let binaryData: Data = try movie.serializedData()
            
            // create the buffer
            var buffer = ctx.channel.allocator.buffer(capacity: binaryData.count)
            
            // write the data to the buffer
            buffer.write(bytes: binaryData)
            
            // create a promise and close the channel when the promise is fulfilled
            let promise: EventLoopPromise<Void> = ctx.eventLoop.newPromise()
            promise.futureResult.whenComplete {
                print("Sent data, closing the channel")
                ctx.close(promise: nil)
            }
            
            // write and flush the data
            ctx.writeAndFlush(wrapOutboundOut(buffer), promise: promise)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error: \(error.localizedDescription)")
        ctx.close(promise: nil)
    }
}
