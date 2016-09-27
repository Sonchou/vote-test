require 'securerandom'
require 'rqrcode'
require 'rqrcode_png'
require 'chunky_png'
require 'rmagick'
class ItemsController < ApplicationController
    
    def new
    end
    
    def show
        render "items"
    end
    
    def index
        @parts = Participant.all
        @votes = Vote.all
    end
    
    def newvote
        number = params[:num].to_i
        voteid = params[:voteid]
        auth = params[:auth]
        code = VotingCode.find_by(voteid: voteid)
        if code.nil?
            render :text => "エラー：無効な投票id"
        else
            if auth == code.auth
                if code.enabled == true
                    code.update(enabled: false)
                    Vote.create(num: number, ip: request.ip)
                    redirect_to :action => "finish"
                else
                    redirect_to :action => "err_used"
                end
            else
                render :text => "エラー：認証に失敗"
            end
        end
    end
    
    def finish
    end
    
    def console
        @votes = Vote.where("ip != ?", "0.0.0.0")
        if params[:cmd] == "delall" and params[:akaza] == "akari"
            VotingCode.delete_all
        end
    end
    
    def add
        Participant.create(
            name: params[:name],
            img: params[:img])
        redirect_to :action => "index"
    end
    
    def gencode
        voteid = VotingCode.count.to_s
        auth = SecureRandom.hex(4)
        VotingCode.create(
            voteid: voteid,
            auth: auth,
            enabled: true)
        url = "https://vote-sonchou.c9users.io/vote?voteid="+voteid+"&auth="+auth
        # QRコード生成
        qr = RQRCode::QRCode.new( url, :size => 8, :level => :h )
        png = qr.to_img
        png.resize(100, 100).save("app/assets/images/qr_#{voteid}.png")
        @qr = "qr_#{voteid}.png"
        @code = url
        render "gencode"
    end
    
    def vote
        @voteid = params[:voteid]
        @auth = params[:auth]
        
        voteid = params[:voteid]
        auth = params[:auth]
        code = VotingCode.find_by(voteid: voteid)
        if code.nil?
            render :text => "エラー：無効な投票id"
        else
            if auth == code.auth
                if code.enabled
                    @parts = Participant.all
                    @votes = Vote.all
                    @voteid = voteid
                else
                    redirect_to :action => "err_used"
                end
            else
                render :text => "エラー：認証に失敗"
            end
        end
    end
    
    def err_used
    end
    
    def pdf
    end
    
    def genpdf
        @page = params[:page].to_i * 10
        arrayQr = []
        arrayCode = []
        for _ in 1..@page do
            voteid = VotingCode.count.to_s
            auth = SecureRandom.hex(4)
            VotingCode.create(
                voteid: voteid,
                auth: auth,
                enabled: true)
            url = "https://vote-sonchou.c9users.io/vote?voteid="+voteid+"&auth="+auth
            # QRコード生成
            qr = RQRCode::QRCode.new( url, :size => 8, :level => :h )
            png = qr.to_img
            png.resize(100, 100).save("app/assets/images/qr_#{voteid}.png")
            arrayQr.push("qr_#{voteid}.png")
            arrayCode.push(url)
        end
        @qr = arrayQr
        @code = arrayCode
    end
    
end
