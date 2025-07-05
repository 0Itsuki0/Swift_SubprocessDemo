//
//  SubprocessDemo.swift
//  AppleContainerDesktop
//
//  Created by Itsuki on 2025/07/05.
//


import Subprocess
import System

import Playgrounds

#Playground {
    // basic
    // with program name
    let lsCommand = Executable.name("ls")
    let lsResult = try await run(lsCommand)
    print(lsResult.processIdentifier) // 46500
    print(lsResult.terminationStatus) // exited(0)
    print(lsResult.standardOutput as Any) // Optional("Desktop\nDocuments\nDownloads\nLibrary\nMovies\nMusic\nPictures\nSystemData\ntmp\n")
    print(lsResult.standardError) // ()

    // with program path
    let printEnvCommand = Executable.path("/usr/bin/printenv")
    let printEnvResult = try await run(printEnvCommand)
    print(printEnvResult)

    // with Argument
    let lsResultWithArg = try await run(lsCommand, arguments: ["-a", "-t"])
    print(lsResultWithArg)
    // equivalent to above
    // let config: Configuration = .init(executable: lsCommand, arguments: ["-a", "-t"])
    // let lsResultWithArg = try await run(config)

    
    // set Environment
    // Inherit the environment values from parent process and add `key=value`
    let inheritAndAddNewEnv = try await run(
        printEnvCommand,
        environment: .inherit.updating(["key": "value"])
    )
    print(inheritAndAddNewEnv)
    
    // clear all and add `key=value`
    let clearEnvAndAddNew = try await run(
        printEnvCommand,
        environment: .custom(["key1": "value1", "key2": "value2"])
    )
    print(clearEnvAndAddNew)


    // set working directory
    let setWorkingDirectory = try await run(
        .name("pwd"),
        workingDirectory: "/Users/"
    )
    print(setWorkingDirectory)
    
    // customize input/output
    // By default, Subprocess:
    //
    // Doesn’t send any input to the child process’s standard input
    // Captures the child process’s standard output as a String, up to 128kB
    // Ignores the child process’s standard error
    let setInputOutputError = try await run(
        .name("cat"),
        input: .string("Hello", using: UTF8.self),
        output: .string,
        error: .string
    )
    print(setInputOutputError)
    
    
    //  custom closure for more control
    // example: only get the first env
    async let monitorResult = run(
        printEnvCommand,
        environment: .custom(["key1" : "value1", "key2" : "value2"])
    ) { execution, standardInput, standardOutput in
        var s = ""
        for try await line in standardOutput.lines(encoding: UTF8.self) {
            print(line)
            s = line
            break
        }
        return s
    }
    
    let result = try await monitorResult
    print(result)
    // ExecutionResult(
    //   terminationStatus: exited(0),
    //   value: key2=value2
    // )

}
