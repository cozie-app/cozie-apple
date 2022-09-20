//
// Created by Federico Tartarini on 11/5/22.
// Copyright (c) 2022 Federico Tartarini. All rights reserved.
//

import Foundation

struct Question: Codable {
    let title: String
    let identifier: String
    let options: Array<String>
    let icons: Array<String>
    let nextQuestion: Array<Int>
}

struct Flow: Codable {
    let title: String
    let questions: Array<Question>
}

var questionFlows = [Flow]()

func defineQuestionFlows() {

    questionFlows = [
        Flow(title: "Perceived Comfort (long, WSU)", questions: [
            Question(
                    title: "Where are you?",
                    identifier: "location",
                    options: [
                        "Indoors",
                        "Outdoors",
                        "Transportation"
                    ],
                    icons: [
                        "indoor",
                        "outdoor-2",
                        "transportation"
                    ],
                    nextQuestion: [
                        2,
                        11,
                        1
                    ]
            ),
            Question(
                    title: "What kind of transport?",
                    identifier: "transport",
                    options: [
                        "Public transport",
                        "Private transport",
                        "Walking/Biking", 
                        "Other"
                    ],
                    icons: [
                        "bus",
                        "car",
                        "outdoor-2",
                        "other"
                    ],
                    nextQuestion: [
                        11,
                        11,
                        11,
                        11
                    ]
            ),
            Question(
                    title: "Where indoors?",
                    identifier: "location-indoor",
                    options: [
                        "Office",
                        "Class",
                        "Home", 
                        "Other"
                    ],
                    icons: [
                        "office",
                        "classroom",
                        "home",
                        "other"
                    ],
                    nextQuestion: [
                        3,
                        11,
                        11,
                        11
                    ]
            ),
            Question(
                    title: "What kind of office?",
                    identifier: "office-type",
                    options: [
                        "Individual",
                        "Small shared",
                        "Large open plan",
                        "Cubicles",
                        "Conference room"
                    ],
                    icons: [
                        "personal",
                        "shared",
                        "open-space",
                        "cubicles",
                        "conference-room"
                    ],
                    nextQuestion: [
                        4,
                        4,
                        4,
                        4
                    ]
            ),
            Question(
                    title: "Are you near a sensor?",
                    identifier: "sensor",
                    options: [
                        "Office - Private",
                        "Office - Shared",
                        "No"
                    ],
                    icons: [
                        "office",
                        "shared",
                        "no3"
                    ],
                    nextQuestion: [
                        5,
                        5,
                        11
                    ]
            ),
            Question(
                    title: "Have you changed location, activity, or clothing in the last 5-minutes?",
                    identifier: "changes",
                    options: [
                        "Yes",
                        "No"
                    ],
                    icons: [
                        "yes-green",
                        "no-red"
                    ],
                    nextQuestion: [
                        11,
                        6
                    ]
            ),
            Question(
                    title: "How would you prefer to be?",
                    identifier: "preference-thermal",
                    options: [
                        "Cooler",
                        "No change",
                        "Warmer"
                    ],
                    icons: [
                        "tp-cooler",
                        "comfortable",
                        "tp-warmer"
                    ],
                    nextQuestion: [
                        7,
                        7,
                        7
                    ]
            ),
            Question(
                    title: "Light preference?",
                    identifier: "preference-light",
                    options: [
                        "Dimmer",
                        "No Change",
                        "Brighter"
                    ],
                    icons: [
                        "dimmer2",
                        "comfortable",
                        "brigher2"
                    ],
                    nextQuestion: [
                        8,
                        8,
                        8
                    ]
            ),
            Question(
                    title: "Sound preference?",
                    identifier: "preference-sound",
                    options: [
                        "Quieter",
                        "No change",
                        "Louder"
                    ],
                    icons: [
                        "quiet",
                        "comfortable",
                        "loud"
                    ],
                    nextQuestion: [
                        9,
                        9,
                        9
                    ]
            ),
            Question(
                    title: "What clothes are you wearing?",
                    identifier: "clothes",
                    options: [
                        "Light",
                        "Medium",
                        "Heavy",
                        "Very heavy"
                    ],
                    icons: [
                        "clothes-light",
                        "clothes-medium",
                        "clothes-heavy",
                        "clothes-very-heavy"
                    ],
                    nextQuestion: [
                        10,
                        10,
                        10,
                        10
                    ]
            ),
            Question(
                    title: "Are you using thermal equipment?",
                    identifier: "equipment",
                    options: [
                        "Fan",
                        "Space heater",
                        "None"
                    ],
                    icons: [
                        "tp-cooler",
                        "space-heater",
                        "none"
                    ],
                    nextQuestion: [
                        11,
                        11,
                        11
                    ]
            )
        ]),
        Flow(title: "Perceived Comfort (short, WSU)", questions: [
            Question(
                    title: "Where are you?",
                    identifier: "location",
                    options: [
                        "In office",
                        "Out of office"
                    ],
                    icons: [
                        "indoor",
                        "outdoor-2",
                    ],
                    nextQuestion: [
                        1,
                        6,
                    ]
            ),
            Question(
                    title: "Are you near a sensor?",
                    identifier: "sensor",
                    options: [
                        "Office - Private",
                        "Office - Shared",
                        "No"
                    ],
                    icons: [
                        "indoor",
                        "shared",
                        "no3"
                    ],
                    nextQuestion: [
                        2,
                        2,
                        6
                    ]
            ),
            Question(
                    title: "Have you changed location, activity, or clothing in the last 5-mitutes?",
                    identifier: "changes",
                    options: [
                        "Yes",
                        "No"
                    ],
                    icons: [
                        "yes-green",
                        "no-red",
                    ],
                    nextQuestion: [
                        6,
                        3,
                    ]
            ),
            Question(
                    title: "How would you prefer to be?",
                    identifier: "preference-thermal",
                    options: [
                        "Cooler",
                        "No change",
                        "Warmer"
                    ],
                    icons: [
                        "tp-cooler",
                        "comfortable",
                        "tp-warmer"
                    ],
                    nextQuestion: [
                        4,
                        4,
                        4
                    ]
            ),
            Question(
                    title: "What clothes are you wearing?",
                    identifier: "clothes",
                    options: [
                        "Light",
                        "Medium",
                        "Heavy",
                        "Very heavy"
                    ],
                    icons: [
                        "clothes-light",
                        "clothes-medium",
                        "clothes-heavy",
                        "clothes-very-heavy"
                    ],
                    nextQuestion: [
                        5,
                        5,
                        5,
                        5
                    ]
            ),
            Question(
                    title: "Are you using thermal equipment?",
                    identifier: "equipment",
                    options: [
                        "Fan",
                        "Space heater",
                        "None"
                    ],
                    icons: [
                        "tp-cooler",
                        "space-heater",
                        "none"
                    ],
                    nextQuestion: [
                        6,
                        6,
                        6
                    ]
            )
        ]),
        Flow(title: "Air Quality (WSU)", questions: [
            Question(
                    title: "Where are you?",
                    identifier: "location",
                    options: [
                        "Indoors",
                        "Outdoors",
                        "Transportation"
                    ],
                    icons: [
                        "indoor",
                        "outdoor-2",
                        "transportation"
                    ],
                    nextQuestion: [
                        2,
                        11,
                        1
                    ]
            ),
            Question(
                    title: "What kind of transport?",
                    identifier: "transport",
                    options: [
                        "Public transport",
                        "Private transport",
                        "Walking/Biking",
                        "Other"
                    ],
                    icons: [
                        "bus",
                        "car",
                        "outdoor-2",
                        "other"
                    ],
                    nextQuestion: [
                        11,
                        11,
                        11,
                        11
                    ]
            ),
            Question(
                    title: "Where indoors?",
                    identifier: "location-indoor",
                    options: [
                        "Office",
                        "Class",
                        "Home",
                        "Other"
                    ],
                    icons: [
                        "office",
                        "classroom",
                        "home",
                        "other"
                    ],
                    nextQuestion: [
                        3,
                        11,
                        11,
                        11
                    ]
            ),
            Question(
                    title: "What kind of office?",
                    identifier: "office-type",
                    options: [
                        "Individual",
                        "Small shared",
                        "Large open plan",
                        "Cubicles", 
                        "Conference room"
                    ],
                    icons: [
                        "personal",
                        "shared",
                        "open-space",
                        "cubicles",
                        "conference-room"
                    ],
                    nextQuestion: [
                        4,
                        4,
                        4,
                        4,
                        4
                    ]
            ),
            Question(
                    title: "Are you near a sensor?",
                    identifier: "sensor",
                    options: [
                        "Office - Private",
                        "Office - Shared",
                        "No"
                    ],
                    icons: [
                        "office",
                        "shared",
                        "no3"
                    ],
                    nextQuestion: [
                        5,
                        5,
                        11
                    ]
            ),
            Question(
                    title: "Can you perceive air movement?",
                    identifier: "air-movement",
                    options: [
                        "Yes",
                        "No"
                    ],
                    icons: [
                        "yes-green",
                        "no-red"
                    ],
                    nextQuestion: [
                        6,
                        8
                    ]
            ),
            Question(
                    title: "Should the air movement be...",
                    identifier: "preference-air",
                    options: [
                        "Less",
                        "No change",
                        "More"
                    ],
                    icons: [
                        "air-mov-less",
                        "air-mov-no-change",
                        "air-mov-more"
                    ],
                    nextQuestion: [
                        7,
                        7,
                        7
                    ]
            ),
            Question(
                    title: "Are you using thermal equipment?",
                    identifier: "equipment",
                    options: [
                        "Fan",
                        "Space heater",
                        "None"
                    ],
                    icons: [
                        "tp-cooler",
                        "space-heater",
                        "none"
                    ],
                    nextQuestion: [
                        8,
                        8,
                        8
                    ]
            ),
            Question(
                    title: "The air is ...",
                    identifier: "air-quality",
                    options: [
                        "Stuffy",
                        "Fresh"
                    ],
                    icons: [
                        "sad-red",
                        "comfortable"
                    ],
                    nextQuestion: [
                        10,
                        9,
                    ]
            ),
            Question(
                    title: "Do you feel...",
                    identifier: "alertness",
                    options: [
                        "Sleepy",
                        "Alert"
                    ],
                    icons: [
                        "sleepy",
                        "comfortable"
                    ],
                    nextQuestion: [
                        11,
                        11
                    ]
            ),
            Question(
                    title: "The bad air comes from...",
                    identifier: "air-pollution-source",
                    options: [
                        "Spoilt food",
                        "Outside",
                        "Other",
                        "Unkown"
                    ],
                    icons: [
                        "food-spoilt",
                        "tp-warmer",
                        "other",
                        "question-mark"
                    ],
                    nextQuestion: [
                        11,
                        11,
                        11,
                        11
                    ]
            )
        ]),
        Flow(title: "Thermal", questions: [
            Question(
                    title: "How would you prefer to be?",
                    identifier: "tc_preference",
                    options: [
                        "Cooler",
                        "No Change",
                        "Warmer"
                    ],
                    icons: [
                        "tp-cooler",
                        "comfortable",
                        "tp-warmer"
                    ],
                    nextQuestion: [
                        1,
                        1,
                        1
                    ]
            ),
            Question(
                    title: "Light preference",
                    identifier: "light_preference",
                    options: [
                        "Dimmer",
                        "No Change",
                        "Brighter"
                    ],
                    icons: [
                        "dimmer",
                        "comfortable",
                        "brighter"
                    ],
                    nextQuestion: [
                        2,
                        2,
                        2
                    ]
            ),
            Question(
                    title: "Sound preference",
                    identifier: "sound_preference",
                    options: [
                        "Quieter",
                        "No Change",
                        "Louder"
                    ],
                    icons: [
                        "quieter",
                        "comfortable",
                        "louder"
                    ],
                    nextQuestion: [
                        3,
                        3,
                        3
                    ]
            ),
            Question(
                    title: "Are you?",
                    identifier: "are_you",
                    options: [
                        "Outdoor",
                        "Indoor"
                    ],
                    icons: [
                        "outdoor",
                        "indoor"
                    ],
                    nextQuestion: [
                        4,
                        4
                    ]
            ),
            Question(
                    title: "Where are you?",
                    identifier: "location_place",
                    options: [
                        "Home",
                        "Office",
                        "Vehicle",
                        "Other"
                    ],
                    icons: [
                        "loc-home",
                        "loc-office",
                        "loc-vehicle",
                        "loc-other"
                    ],
                    nextQuestion: [
                        5,
                        5,
                        5,
                        5
                    ]
            ),
            Question(
                    title: "Are you near a sensor?",
                    identifier: "near_sensor?",
                    options: [
                        "Home",
                        "Work",
                        "Portable",
                        "No"
                    ],
                    icons: [
                        "loc-home",
                        "loc-office",
                        "backpack",
                        "no2"
                    ],
                    nextQuestion: [
                        6,
                        6,
                        6,
                        6
                    ]
            ),
            Question(
                    title: "What mood are you in?",
                    identifier: "mood",
                    options: [
                        "Bad",
                        "Good",
                       "Neither"
                    ],
                    icons: [
                        "mood-bad",
                        "mood-good",
                        "mood-neutral"
                    ],
                    nextQuestion: [
                        7,
                        7,
                        7
                    ]
            ),
            Question(
                    title: "What clothes are you wearing?",
                    identifier: "clo",
                    options: [
                        "Very light",
                        "Light",
                        "Medium",
                        "Heavy"
                    ],
                    icons: [
                        "clo-very-light",
                        "clo-light",
                        "clo-medium",
                        "clo-heavy"
                    ],
                    nextQuestion: [
                        8,
                        8,
                        8,
                        8
                    ]
            ),
            Question(
                    title: "Have you changed location, activity or clothing over the last 10-min?",
                    identifier: "changed_location",
                    options: [
                        "Yes",
                        "No"
                    ],
                    icons: [
                        "yes",
                        "no"
                    ],
                    nextQuestion: [
                        9,
                        9
                    ]
            )
        ]),
        Flow(title: "Movement", questions: [
            Question(
                    title: "In the past 60min, I used",
                    identifier: "last_60min",
                    options: [
                        "Lift",
                        "Stairs",
                        "Both",
                        "Neither"
                    ],
                    icons: [
                        "elevator",
                        "stairs",
                        "both",
                        "neither"
                    ],
                    nextQuestion: [
                        1,
                        2,
                        9,
                        5
                    ]
            ),
            Question(
                    title: "Took lift, why?",
                    identifier: "lift_why",
                    options: [
                        "Convenient",
                        "Less effort",
                        "No stairs"
                    ],
                    icons: [
                        "convenience",
                        "less-effort",
                        "nostairs"
                    ],
                    nextQuestion: [
                        3,
                        5,
                        5
                    ]
            ),
            Question(
                    title: "Took stairs, why?",
                    identifier: "stairs_why",
                    options: [
                        "Convenient",
                        "No lift",
                        "Save energy",
                        "Healthy"
                    ],
                    icons: [
                        "convenience",
                        "no-elevator",
                        "save-energy",
                        "fitness"
                    ],
                    nextQuestion: [
                        4,
                        5,
                        5,
                        5
                    ]
            ),
            Question(
                    title: "Lift convenient because?",
                    identifier: "lift_con",
                    options: [
                        "Easiest",
                        "Fastest",
                        "Both"
                    ],
                    icons: [
                        "easier",
                        "faster",
                        "both"
                    ],
                    nextQuestion: [
                        5,
                        5,
                        5
                    ]
            ),
            Question(
                    title: "Stairs convenient because",
                    identifier: "stairs_con",
                    options: [
                        "Easiest",
                        "Fastest",
                        "Both"
                    ],
                    icons: [
                        "easier",
                        "faster",
                        "both"
                    ],
                    nextQuestion: [
                        5,
                        5,
                        5
                    ]
            ),
            Question(
                    title: "Are you working right now?",
                    identifier: "working",
                    options: [
                        "Yes",
                        "No"
                    ],
                    icons: [
                        "yes",
                        "no"
                    ],
                    nextQuestion: [
                        6,
                        8
                    ]
            ),
            Question(
                    title: "What kind of workstation?",
                    identifier: "workstation",
                    options: [
                        "Adjustable",
                        "Standing",
                        "Sitting"
                    ],
                    icons: [
                        "adjustable",
                        "standing",
                        "sitting"
                    ],
                    nextQuestion: [
                        7,
                        8,
                        8
                    ]
            ),
            Question(
                    title: "Adjusted height today?",
                    identifier: "adj_height",
                    options: [
                        "Up & down",
                        "Down",
                        "Up",
                        "Never"
                    ],
                    icons: [
                        "adjustable",
                        "down",
                        "up",
                        "never"
                    ],
                    nextQuestion: [
                        8,
                        8,
                        8,
                        8
                    ]
            ),
            Question(
                    title: "Are you",
                    identifier: "current",
                    options: [
                        "Standing",
                        "Sitting"
                    ],
                    icons: [
                        "standing",
                        "sitting"
                    ],
                    nextQuestion: [
                        12,
                        12
                    ]
            ), Question(
                    title: "Took lift, why?",
                    identifier: "lift_why",
                    options: [
                        "Convenient",
                        "Less effort",
                        "No stairs"
                    ],
                    icons: [
                        "convenience",
                        "less-effort",
                        "nostairs"
                    ],
                    nextQuestion: [
                        11,
                        10,
                        10
                    ]
            ), Question(
                    title: "Took stairs, why?",
                    identifier: "stairs_why",
                    options: [
                        "Convenient",
                        "No lift",
                        "Save energy",
                        "Healthy"
                    ],
                    icons: [
                        "convenience",
                        "no-elevator",
                        "save-energy",
                        "fitness"
                    ],
                    nextQuestion: [
                        4,
                        5,
                        5,
                        5
                    ]
            ), Question(
                    title: "Lift convenient because?",
                    identifier: "lift_con",
                    options: [
                        "Easiest",
                        "Fastest",
                        "Both"
                    ],
                    icons: [
                        "easier",
                        "faster",
                        "both"
                    ],
                    nextQuestion: [
                        10,
                        10,
                        10
                    ]
            )
        ]
        ),
        Flow(title: "Privacy", questions: [
            Question(
                    title: "Alone or in a group?",
                    identifier: "alone_group",
                    options: [
                        "Alone",
                        "Online",
                        "Group"
                    ],
                    icons: [
                        "alone-privacy",
                        "online-privacy",
                        "group-privacy"
                    ],
                    nextQuestion: [
                        4,
                        1,
                        10
                    ]
            ),
            Question(
                    title: "Category of activity?",
                    identifier: "activity",
                    options: [
                        "Socialize",
                        "Collaborate",
                        "Learn"
                    ],
                    icons: [
                        "socialize-privacy",
                        "collaborate-privacy",
                        "learn-privacy"
                    ],
                    nextQuestion: [
                        3,
                        3,
                        3
                    ]
            ),
            Question(
                    title: "Possibly distracting others?",
                    identifier: "distracting",
                    options: [
                        "Yes",
                        "No"
                    ],
                    icons: [
                        "yes",
                        "no"
                    ],
                    nextQuestion: [
                        3,
                        3
                    ]
            ),
            Question(
                    title: "Distractions nearby?",
                    identifier: "distractions",
                    options: [
                        "None",
                        "A little",
                        "A lot"
                    ],
                    icons: [
                        "none",
                        "little",
                        "lot"
                    ],
                    nextQuestion: [
                        5,
                        6,
                        6
                    ]
            ),
            Question(
                    title: "Category of activity?",
                    identifier: "activity",
                    options: [
                        "Focus",
                        "Leisure"
                    ],
                    icons: [
                        "focus-privacy",
                        "leisure-privacy"
                    ],
                    nextQuestion: [
                        3,
                        3
                    ]
            ),
            Question(
                    title: "Feeling like you need more privacy?",
                    identifier: "more_privacy",
                    options: [
                        "Yes",
                        "No"
                    ],
                    icons: [
                        "yes",
                        "no"
                    ],
                    nextQuestion: [
                        7,
                        11
                    ]
            ),
            Question(
                    title: "What kind of distraction",
                    identifier: "kind_distraction",
                    options: [
                        "Visual",
                        "Audio",
                        "Others"
                    ],
                    icons: [
                        "visual-privacy",
                        "noise-privacy",
                        "others"
                    ],
                    nextQuestion: [
                        5,
                        5,
                        8
                    ]
            ),
            Question(
                    title: "Why is more privacy needed?",
                    identifier: "why_more_privacy",
                    options: [
                        "See me",
                        "Hear me",
                        "Both"
                    ],
                    icons: [
                        "visual-privacy",
                        "noise-privacy",
                        "both"
                    ],
                    nextQuestion: [
                        9,
                        11,
                        9
                    ]
            ),
            Question(
                    title: "What is it?",
                    identifier: "what_privacy",
                    options: [
                        "Thermal",
                        "Scent",
                        "Glare"
                    ],
                    icons: [
                        "thermal-privacy",
                        "scent-privacy",
                        "glare-privacy"
                    ],
                    nextQuestion: [
                        5,
                        5,
                        5
                    ]
            ),
            Question(
                    title: "What do people see?",
                    identifier: "people_see",
                    options: [
                        "Appearance",
                        "Work",
                        "Behaviour"
                    ],
                    icons: [
                        "appearance",
                        "work",
                        "activity"
                    ],
                    nextQuestion: [
                        11,
                        11,
                        11
                    ]
            ),
            Question(
                    title: "Category of activity?",
                    identifier: "activity",
                    options: [
                        "Socialize",
                        "Collaborate",
                        "Learn"
                    ],
                    icons: [
                        "socialize-privacy",
                        "collaborate-privacy",
                        "learn-privacy"
                    ],
                    nextQuestion: [
                        2,
                        2,
                        2
                    ]
            ),
        ]),
        Flow(title: "Infection Risk", questions: [
            Question(
                    title: "Do your surroundings increase infection risk?",
                    identifier: "surroundings_infection",
                    options: [
                        "Not at all",
                        "A Little",
                        "A lot"
                    ],
                    icons: [
                        "shield",
                        "1virus",
                        "3virus"
                    ],
                    nextQuestion: [
                        1,
                        2,
                        2
                    ]
            ),
            Question(
                    title: "Currently, how many people are within 5m?",
                    identifier: "within_5m",
                    options: [
                        "0 pax",
                        "1-4 pax",
                        "5+ pax"
                    ],
                    icons: [
                        "0pax",
                        "0-4pax",
                        "5pax"
                    ],
                    nextQuestion: [
                        4,
                        4,
                        4
                    ]
            ),
            Question(
                    title: "What causes more risk?",
                    identifier: "cause_risk",
                    options: [
                        "Ventilation",
                        "People",
                        "Surface"
                    ],
                    icons: [
                        "ventilation",
                        "people",
                        "surface"
                    ],
                    nextQuestion: [
                        1,
                        3,
                        1
                    ]
            ),
            Question(
                    title: "Specifically, what concerns you?",
                    identifier: "concerns",
                    options: [
                        "Density",
                        "Proximity",
                        "Both"
                    ],
                    icons: [
                        "density",
                        "proximity",
                        "both"
                    ],
                    nextQuestion: [
                        1,
                        1,
                        1
                    ]
            ),

        ])
    ]


}
