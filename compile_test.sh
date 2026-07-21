swiftc -parse-as-library \
    -target x86_64-apple-ios15.0-simulator \
    -sdk $(xcrun --show-sdk-path --sdk iphonesimulator) \
    ShiftPlanner/*.swift ShiftPlanner/Models/*.swift ShiftPlanner/Views/*.swift
