require 'rest-client'
require 'json'

$owner = "SzFMV2018-Tavasz"
$repo = "release-test"
$tag = "nightly"
$filename = "./target/release-test.jar"
$filename_label="release-test.jar"
$GH_TOKEN = ARGV[0]
$commit = %x(git log --format=%H -1)
$release_msg = "Nightly build based on #{$commit} at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

def create_release
    response = JSON.parse(RestClient.post "https://api.github.com/repos/#{$owner}/#{$repo}/releases?access_token=#{$GH_TOKEN}", {tag_name: $tag, target_commitish: "master", name: "nightly", body: $release_msg, draft: false, prerelease: true}.to_json)
    
    RestClient::Request.execute(method: :post, url: response["upload_url"][0..-14] + "?name='#{$filename_label}'&label=Single runnable jar&access_token=#{$GH_TOKEN}", payload: File.new($filename, "rb"), headers: {'Content-Type': 'application/zip'})
end

begin
    get = JSON.parse(RestClient.get "https://api.github.com/repos/#{$owner}/#{$repo}/releases/tags/#{$tag}?access_token=#{$GH_TOKEN}")
    RestClient.delete "https://api.github.com/repos/#{$owner}/#{$repo}/releases/#{get["id"]}?access_token=#{$GH_TOKEN}"
    
    # %x(git tag -d #{$tag})
    # %x(git push origin :refs/tags/#{$tag})
    
    # latest = JSON.parse(RestClient.get "https://api.github.com/repos/#{$owner}/#{$repo}/git/refs/heads/master")
    
    # create new build only if the last commit differs
    # if get["body"].include? $commit then
    # if get["body"].include? latest["object"]["sha"] then
        # puts "No changes from the last nightly build"
    # else
        # RestClient::Request.execute(method: :delete, url: "https://api.github.com/repos/#{$owner}/#{$repo}/releases/#{get["id"]}?access_token=#{$GH_TOKEN}")
        create_release
    # end
rescue RestClient::ExceptionWithResponse => err
    case err.http_code
    when 404 # if there was no release with the given name
        create_release
    else
        raise
    end
end
