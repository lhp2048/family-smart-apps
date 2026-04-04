String taskGroupKey(String bizDate, String groupCode) => '$bizDate|$groupCode';

String taskItemKey(String bizDate, String groupCode, String taskCode) =>
    '$bizDate|$groupCode|$taskCode';
