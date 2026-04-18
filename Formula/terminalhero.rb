class Terminalhero < Formula
  desc "Terminal-based Guitar Hero-style game"
  homepage "https://github.com/ciembor/TerminalHero"
  url "https://github.com/ciembor/TerminalHero.git",
      revision: "c17a4fdae5f6fa4eb632d1537e081c5de80113db"
  version "1.0"
  license "MIT"

  depends_on "pkgconf" => :build
  depends_on "libtermkey"
  depends_on "perl"

  resource "Module-Build" do
    url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/Module-Build-0.4234.tar.gz"
    sha256 "66aeac6127418be5e471ead3744648c766bd01482825c5b66652675f2bc86a8f"
  end

  resource "ExtUtils-PkgConfig" do
    url "https://cpan.metacpan.org/authors/id/X/XA/XAOC/ExtUtils-PkgConfig-1.16.tar.gz"
    sha256 "bbeaced995d7d8d10cfc51a3a5a66da41ceb2bc04fedcab50e10e6300e801c6e"
  end

  resource "Module-Build-Using-PkgConfig" do
    url "https://cpan.metacpan.org/authors/id/P/PE/PEVANS/Module-Build-Using-PkgConfig-0.03.tar.gz"
    sha256 "11774a6914bcfa0915f9f01c3041b16878d52ad86d83ecedbe62e68d4f41ecc1"
  end

  resource "IO-Pipely" do
    url "https://cpan.metacpan.org/authors/id/R/RC/RCAPUTO/IO-Pipely-0.006.tar.gz"
    sha256 "0e3fcd841a327efb549fa01b2083dc3695e72ea0c63303e56ed5161bf810413b"
  end

  resource "TermReadKey" do
    url "https://cpan.metacpan.org/authors/id/J/JS/JSTOWE/TermReadKey-2.38.tar.gz"
    sha256 "5a645878dc570ac33661581fbb090ff24ebce17d43ea53fd22e105a856a47290"
  end

  resource "POE-Test-Loops" do
    url "https://cpan.metacpan.org/authors/id/R/RC/RCAPUTO/POE-Test-Loops-1.360.tar.gz"
    sha256 "bed0c96fe91c98fd37e6eb59a804aaac9cc4a9e928450b76d4bf5527a9e6a47b"
  end

  resource "POE" do
    url "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/POE-1.370.tar.gz"
    sha256 "57de2b635b15fa3a31a9e55dd51122149e5414e1158ee82235062634ee18a693"
  end

  resource "Term-TermKey" do
    url "https://cpan.metacpan.org/authors/id/P/PE/PEVANS/Term-TermKey-0.19.tar.gz"
    sha256 "381ce4b32b364da0f297ffa08387871084a5beaaa4d9d15dde1b00e646347bae"
  end

  resource "POE-Wheel-TermKey" do
    url "https://cpan.metacpan.org/authors/id/P/PE/PEVANS/POE-Wheel-TermKey-0.02.tar.gz"
    sha256 "05a8e72c285b0bced5c78a6d9bf0074fe10daad6bd3469e3985d323ac98fb2e3"
  end

  def perl
    Formula["perl"].opt_bin/"perl"
  end

  def perl5lib_paths
    paths = [libexec/"lib/perl5"]
    paths.concat Dir["#{libexec}/lib/perl5/*"].select { |path| File.directory?(path) }
    paths
  end

  def with_perl5lib
    (libexec/"lib/perl5").mkpath
    perl5lib_paths.each { |path| ENV.prepend_path "PERL5LIB", path }
  end

  def install_perl_module(resource_name)
    resource(resource_name).stage do
      with_perl5lib

      if File.exist?("Makefile.PL")
        args = ["Makefile.PL", "INSTALL_BASE=#{libexec}"]
        args << "--default" if resource_name == "POE"
        system perl, *args
        system "make"
        system "make", "install"
      elsif File.exist?("Build.PL")
        system perl, "Build.PL", "--install_base", libexec
        system "./Build"
        system "./Build", "install"
      else
        odie "No supported Perl build file found"
      end
    end
  end

  def install
    %w[
      Module-Build
      ExtUtils-PkgConfig
      Module-Build-Using-PkgConfig
      IO-Pipely
      TermReadKey
      POE-Test-Loops
      POE
      Term-TermKey
      POE-Wheel-TermKey
    ].each { |resource_name| install_perl_module(resource_name) }

    libexec.install "terminalhero"
    inreplace libexec/"terminalhero", /^#!.*/, "#!#{perl}"
    chmod 0755, libexec/"terminalhero"

    (bin/"terminalhero").write_env_script libexec/"terminalhero",
                                          PERL5LIB: perl5lib_paths.join(":")
  end

  test do
    includes = perl5lib_paths.map { |path| "-I#{path}" }.join(" ")
    assert_match(/syntax OK/, shell_output("#{perl} #{includes} -c #{libexec}/terminalhero 2>&1"))
    assert_match(/Usage: terminalhero/, shell_output("#{bin}/terminalhero --help"))
  end
end
