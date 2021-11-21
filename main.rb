require 'pathname'
require 'aes'
require "test/unit/assertions"
include Test::Unit::Assertions

class Main
    $save_file = "./passwords.key"

    def remove_account website
	    lines = File.readlines($save_file)
	    File.open($save_file, 'w'){|file| file.truncate(0)} #Empty the files content

	    for i in 0 ... lines.length()
	    	next if lines[i] == nil
	    	if lines[i].start_with?(website)
	    		lines.delete_at(i)
	    	end
	    end

	    	File.open($save_file, 'w+') do |f|
	    		f.puts lines
	    end
    end

    def search_for_website website
        lines = File.readlines($save_file)

        for i in 0 ... lines.length()
            next if lines[i] == nil
            if lines[i].start_with?(website)
                tokens = lines[i].split(":")
                pass = decrypt_passwd tokens[1]
                puts(tokens[0] + " : " + pass)
            end
        end
    end

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

    def process_argv
        main_obj = Main.new
        for arg in 0 ... $flags.length() do
            case $flags[arg]
                when "-k"
                    $master_key = $flags[arg + 1]
                when "-l"
                    main_obj.view_all_passwords
                when "-s"
                    main_obj.search_for_website $flags[arg + 1]
                when "-r"
                    main_obj.remove_account $flags[arg + 1]
                when "-n"
                    credentials = $flags[arg + 1]
                    split = credentials.split(":")
                    website = split[0]
                    password = split[1]
                    main_obj.generate_new website, password
                when "-h"
                    puts "-k provides the key for the encryption and decryption"
                    puts "-l shows all stored passwords "
                    puts "-s searches and prints the provided website/username"
                    puts "-n creates a new account. The format is '-n website:password'"
		    puts "-r to remove credentials of inserted username/website"
            end
        end
    end
end

args_obj = ArgReader.new
args_obj.process_argv
