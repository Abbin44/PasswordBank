require 'pathname'
require 'aes'
require "test/unit/assertions"
include Test::Unit::Assertions

class Main
    $save_file = "/passwords.key"

    def enc_passwd passwd
        enc = AES.encrypt(passwd, $master_key)
        return enc
    end

    def decrypt_passwd passwd
        begin
            dec = AES.decrypt(passwd, $master_key)
            return dec
        rescue => error
            return passwd #If decryption fails, return the encrypted password to ensure security
        end
    end

    def view_all_passwords
        File.readlines($save_file).each do |line|
            next if line == nil
            tokens = line.split(":")
            pass = decrypt_passwd tokens[1]
            puts(tokens[0] + " : " + pass)
        end
    end

    def generate_new website, password
        password = enc_passwd password

        if not File.exist?($save_file)
            Pathname.new($save_file)
        end

        File.open($save_file, "a") {|f| f.puts website + ":" + password}
    end
end

class ArgReader
    $flags = ARGV
    puts $flags.join(" - ")
    def process_argv
        main_obj = Main.new
        for arg in 0 ... $flags.length() do
            case $flags[arg]
                when "-k"
                    $master_key = $flags[arg + 1]
                when "-v"
                    main_obj.view_all_passwords
                when "-n"
                    credentials = $flags[arg + 1]
                    split = credentials.split(":")
                    website = split[0]
                    password = split[1]
                    main_obj.generate_new website, password
                when "-h"
                    puts "-k provides the key for the encryption and decryption"
                    puts "-v shows all stored passwords "
                    puts "-n creates a new account. The format is '-n website:password'"
            end
        end
    end
end

args_obj = ArgReader.new
args_obj.process_argv
#main_obj = Main.new
#main_obj.start
