{ pkgs, lib, stdenv, buildGoModule, fetchFromGitHub }:
let

maingo = pkgs.writeTextFile {
  name = "main.go";
  text = ''  
package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/newrelic/go-agent/v3/integrations/logcontext-v2/nrlogrus"
	newrelic "github.com/newrelic/go-agent/v3/newrelic"
	"github.com/sirupsen/logrus"
)

func doFunction2(txn *newrelic.Transaction, e *logrus.Entry) {
	defer txn.StartSegment("doFunction2").End()
	e.Error("In doFunction2")
}

func doFunction1(txn *newrelic.Transaction, e *logrus.Entry) {
	defer txn.StartSegment("doFunction1").End()
	e.Trace("In doFunction1")
	doFunction2(txn, e)
}

func main() {
	app, err := newrelic.NewApplication(
		newrelic.ConfigAppName("Vagrant ZBan"),
		newrelic.ConfigLicense(os.Getenv("NEW_RELIC_LICENSE_KEY")),
		newrelic.ConfigInfoLogger(os.Stdout),
		newrelic.ConfigAppLogForwardingEnabled(true),

		// If you wanted to forward your logs using a log forwarder instead
		// newrelic.ConfigAppLogDecoratingEnabled(true),
		// newrelic.ConfigAppLogForwardingEnabled(false),
	)
	if nil != err {
		log.Panic("Failed to create application", err)
	}

	log := logrus.New()
	log.SetLevel(logrus.TraceLevel)
	// Enable New Relic log decoration
	log.SetFormatter(nrlogrus.NewFormatter(app, &logrus.TextFormatter{}))
	log.Trace("waiting for connection to New Relic...")

	err = app.WaitForConnection(10 * time.Second)
	if nil != err {
		log.Panic("Failed to connect application", err)
	}
	defer app.Shutdown(10 * time.Second)
	log.Info("application connected to New Relic")
	log.Debug("Starting transaction now")
	txn := app.StartTransaction("main")

	// Add the transaction context to the logger. Only once this happens will
	// the logs be properly decorated with all required fields.
	e := log.WithContext(newrelic.NewContext(context.Background(), txn))

	doFunction1(txn, e)

	e.Info("Ending transaction")
	txn.End()
}
  '';
};


# sum = pkgs.writeTextFile {
#   name = "go.sum";
#   text = ''                                                                         
# github.com/google/go-cmp v0.6.0 h1:ofyhxvXcZhMsU5ulbFiLKl/XBFqE1GSq7atu8tAmTRI=
# github.com/google/go-cmp v0.6.0/go.mod h1:17dUlkBOakJ0+DkrSSNjCkIjxS6bF9zb3elmeNGIjoY=
# golang.org/x/net v0.25.0 h1:d/OCCoBEUq33pjydKrGQhw7IlUPI2Oylr+8qLx49kac=
# golang.org/x/net v0.25.0/go.mod h1:JkAGAh7GEvH74S6FOH42FLoXpXbE/aqXSrIQjXgsiwM=
# golang.org/x/sys v0.20.0 h1:Od9JTbYCk261bKm4M/mw7AklTlFYIa0bIp9BgSm1S8Y=
# golang.org/x/sys v0.20.0/go.mod h1:/VUhepiaJMQUp4+oa/7Zr1D23ma6VTLIYjOOTFZPUcA=
# golang.org/x/text v0.15.0 h1:h1V/4gjBv8v9cjcR6+AR5+/cIYK5N/WAgiv4xlsEtAk=
# golang.org/x/text v0.15.0/go.mod h1:18ZOQIKpY8NJVqYksKHtTdi31H5itFRjB5/qKTNYzSU=
# google.golang.org/genproto/googleapis/rpc v0.0.0-20240528184218-531527333157 h1:Zy9XzmMEflZ/MAaA7vNcoebnRAld7FsPW1EeBB7V0m8=
# google.golang.org/genproto/googleapis/rpc v0.0.0-20240528184218-531527333157/go.mod h1:EfXuqaE1J41VCDicxHzUDm+8rk+7ZdXzHV0IhO/I6s0=
# google.golang.org/grpc v1.65.0 h1:bs/cUb4lp1G5iImFFd3u5ixQzweKizoZJAwBNLR42lc=
# google.golang.org/grpc v1.65.0/go.mod h1:WgYC2ypjlB0EiQi6wdKixMqukr6lBc0Vo+oOgjrM5ZQ=
# google.golang.org/protobuf v1.34.2 h1:6xV6lTsCfpGD21XK49h7MhtcApnLqkfYgPcdHftf6hg=
# google.golang.org/protobuf v1.34.2/go.mod h1:qYOHts0dSfpeUzUFpOMr/WGzszTmLH+DiWniOlNbLDw=
#   '';
# };

in
  buildGoModule rec {
# stdenv.mkDerivation rec {
    pname = "go-agent";
    version = "3.36.0";
    inherit maingo;

  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "go-agent";
    rev =  "v${version}";
    hash = "sha256-om2HGQU+PYOwKWfaWzdZSTq8nll6gV6kxT8TLd8LdUM=";
    postFetch = ''
      export PATH="${pkgs.git}/bin:${pkgs.go}/bin:$PATH"
      export HOME=$(pwd)
      cd $out/v3
      chmod -R 777 .
      go mod tidy
      go mod vendor
      cd $out/v3/integrations/logcontext-v2/nrwriter
      cp ${maingo} main.go
      go mod tidy
      go mod vendor
    '';
  };
  
  vendorHash = null;

  modRoot = "./v3";

  buildInputs = [ stdenv pkgs.go pkgs.git ];

  subPackages = [
    "newrelic"
    "integrations/logcontext-v2/nrlogrus"
  ];

  installPhase = ''
    mkdir -p $out
    cp -r /build/* $out
  '';

  env.CGO_ENABLED = "0";
  env.HOME = "$(pwd)";
  env.GOPROXY = "direct";

  checkFlags = [ "-skip TestGenerateAndCompile" ];

  doCheck = false;

}
