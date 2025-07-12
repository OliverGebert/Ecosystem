workspace "Name" "Description" {

    !identifiers hierarchical

    model {
        uweb = person "Web User"
        ulocal = person "Local User"
        ss = softwareSystem "Software System Ecosystem" {
            spa = container "Single Page Application" {
                technology "Vue.js"
            }
            cli = container "Ecosystem CLI" {
                technology "python cli"
            }
            api = container "Ecosystem REST API" {
                technology "Python fastAPI"
            }
            db = container "Database" {
                tags "Database"
                technology "MariaDB"
            }
        }

        uweb -> ss.spa "Uses"
        ulocal -> ss.cli "Uses"
        ss.spa -> ss.api "Reads from and writes to"
        ss.cli -> ss.api "Reads from and writes to"
        ss.api -> ss.db "Reads from writes to"
    }

    views {
        systemContext ss "ContextViewEcosystem" {
            include *
            autolayout tb
        }

        container ss "ContainerViewEcosystem" {
            include *
            autolayout tb
        }

        styles {
            element "Element" {
                color #ffffff
            }
            element "Person" {
                background #2e7d32
                shape person
            }
            element "Software System" {
                background #43a047
            }
            element "Container" {
                background #66bb6a
            }
            element "Database" {
                shape cylinder
                background #388e3c
            }
        }
    }

    configuration {
        scope softwaresystem
    }

}
