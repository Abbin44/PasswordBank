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
        dec = AES.decrypt(passwd, $master_key)
        return dec
    end

    def view_all_passwords
        File.readlines($save_file).each do |line|
            next if line == nil
            tokens = line.split(":")
            pass = decrypt_passwd tokens[1]
            puts(tokens[0] + " : " + pass)
        end
    end

    def generate_new
        system ("clear") || (system "cls")
        puts "Enter the website you want to create a new password for: "
        website = gets.chomp()
        puts "Enter the password you want: "
        password = gets.chomp()
        password = enc_passwd password

        if not File.exist?($save_file)
            Pathname.new($save_file)
        end

        File.open($save_file, "a") {|f| f.puts website + ":" + password}
    end

    def start
        puts "Enter master key"
        $master_key = gets.chomp()
        system ("clear") || (system "cls")

        puts "1) View stored passwords"
        puts "2) Generate a new password"
        puts "3) Help/Information"

        input = gets.chomp()
        case input
            when "1"
                view_all_passwords
            when "2"
                generate_new
            when "3"

            else
                puts "invalid input"
        end
    end
end

object = Main.new
object.start
