workspace "Name" "Description" {

    !identifiers hierarchical

    model {
        u = person "User"
        ss = softwareSystem "Software System Ecosystem" {
            spa = container "Single Page Application" {
                technology "Vue.js"
            }
            api = container "Ecosystem REST API" {
                technology "Python fastAPI"
            }
            db = container "Database" {
                tags "Database"
                technology "MariaDB"
            }
        }

        u -> ss.spa "Uses"
        ss.spa -> ss.api "Reads from and writes to"
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
