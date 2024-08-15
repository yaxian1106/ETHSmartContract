pragma solidity ^0.8.0;

import "./SinglyLinkedList.sol";

import "./strings.sol";

contract TestLink3 {
    using SinglyLinkedList for SinglyLinkedList.List;
    using strings for *;
    //using DateTimeLibrary for *;
 
    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;
 
    SinglyLinkedList.List /*public*/ singlyLinkedList;
 
    Dataset.NodeData[] public preConditionWorkings;
 
    constructor() public {
        Dataset.NodeData memory firtNodeData = Dataset.NodeData("a",0,0,0,"");
        singlyLinkedList.insert(1, firtNodeData);
    }
 
    function _daysToDate(uint _days) private pure returns (uint year, uint month, uint day) {
        int __days = int(_days);
 
        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;
 
        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }
 
    function _daysFromDate(uint year, uint month, uint day) private pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);
 
        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;
 
        _days = uint(__days);
    }
 
    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
 
    function getYear(uint timestamp) internal pure returns (uint year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }
 
    function addDays(uint timestamp, uint _days) private pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
 
    function diffDays(uint fromTimestamp, uint toTimestamp) private pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
 
    function insert(string memory workingType, uint startY, uint startM, uint startD, uint workingDays, uint256 index) public returns(bool) {
        uint timestamp = timestampFromDate(startY,startM,startD);
        Dataset.NodeData memory firtNodeData = Dataset.NodeData(workingType, timestamp, workingDays, 0, "");
        return singlyLinkedList.insert(index, firtNodeData);
    }
 
     
    function getListLength() private view returns(uint256) {
        return singlyLinkedList.head.listLength;
    }
 
     
    function getLinkedListData() public view returns(Dataset.NodeData[] memory) {
        uint256 listLength = getListLength();
        Dataset.NodeData[] memory listData = new Dataset.NodeData[](listLength + 1);
        for(uint256 i=1;i <= listLength;i++) {
            Dataset.NodeData memory nodeData = singlyLinkedList.getNodeData(i);
            listData[i] = nodeData;
        }
        return listData;
    }
 
     
    function getLinkedListData2() public view returns(string memory, Dataset.NodeData[] memory) {
        return ("MainChain", getLinkedListData());
    }
 
     
    function getpreConditionWorkings() public view returns(string memory, Dataset.NodeData[] memory) {
        return ("PreWorkingChain", preConditionWorkings);
    }
 
 
 
    function isEqual(string memory a, string memory b) private pure returns (bool) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        
        if (aa.length != bb.length) return false;
        
        for(uint i = 0; i < aa.length; i ++) {
            if(aa[i] != bb[i]) return false;
        }
 
        return true;
    }
 
 
    function addItem(string memory preWorkingType, 
                        uint startY, uint startM, uint startD, uint workingDays) private {
        if (preConditionWorkings.length > 0){
            for(uint i = 0;i < preConditionWorkings.length; i++){
                if (isEqual(preConditionWorkings[i].workingType, preWorkingType)){
                    return;
                }
            }
        }
 
        uint timestamp = timestampFromDate(startY, startM, startD);
        
        Dataset.NodeData memory data = Dataset.NodeData(preWorkingType, timestamp, workingDays, 0, "");
        preConditionWorkings.push(data);
    }
 
    function removeItem(string memory workingType) private {
        if (preConditionWorkings.length > 0){
            for(uint i = 0;i < preConditionWorkings.length; i++){
                if (isEqual(preConditionWorkings[i].workingType, workingType)){
                    removeAt(i);
                    return;
                }
            }
        }
    }
 
 
    
   function removeAt(uint i) private {
      require(i >= 0 && i < preConditionWorkings.length);
      for (uint k=i; k < preConditionWorkings.length-1; k++){
         preConditionWorkings[k] = preConditionWorkings[k+1];
      }
      preConditionWorkings.pop();
   }
 
 
 
 
     
    function setLinkedListData(string memory typeName, uint256 delayDays) public returns(Dataset.NodeData[] memory) {
        uint256 listLength = getListLength();
        Dataset.NodeData[] memory listData = new Dataset.NodeData[](listLength + 1);
        for(uint256 i=1;i <= listLength;i++) {
            Dataset.NodeData storage nodeData = singlyLinkedList.getNodeData(i);
            if (isEqual(nodeData.workingType,typeName)){
                nodeData.delayDays = nodeData.delayDays + delayDays;
                listData[i] = nodeData;
                
                
                for(uint256 j = i + 1; j <= listLength;j++){
                    Dataset.NodeData storage nodeData2 = singlyLinkedList.getNodeData(j);
                    nodeData2.delayDays = nodeData2.delayDays + delayDays;
                    listData[j] = nodeData2;
                }
 
                break;
            }
 
            listData[i] = nodeData;
        }
        return listData;
    }
 
 
      
    function setLinkedListDelayDays(string memory typeName, uint256 delayDays) public {
        uint256 listLength = getListLength();
        Dataset.NodeData[] memory listData = new Dataset.NodeData[](listLength + 1);
        for(uint256 i=1;i <= listLength;i++) {
 
            Dataset.NodeData storage nodeData = singlyLinkedList.getNodeData(i);
 
            if (isEqual(nodeData.workingType, typeName)){
                nodeData.delayDays = nodeData.delayDays + delayDays;
                listData[i] = nodeData;
                
                return;
            }
        }
    }
 
 
 
    
    function setPreConditionDelayDays(string memory workingType, uint delayDays) public {
        if (isEqual(workingType, ""))
            return;
 
        
        uint256 listLength = getListLength();
        Dataset.NodeData[] memory listData = new Dataset.NodeData[](listLength + 1);
        for(uint256 i=1;i <= listLength;i++) {
            Dataset.NodeData storage nodeData = singlyLinkedList.getNodeData(i);
 
            if (isEqual(nodeData.preConditionWorking, ""))
                continue;
 
            bool containPre = false;
 
            string[] memory strArr = split(nodeData.preConditionWorking, "&");
 
            for(uint ii = 0; ii < strArr.length; ii++) {
                string memory str = strArr[ii];
                if (isEqual(str, workingType)){
                    containPre = true;
                    break;
                }
            }
 
            if (containPre == false)
                continue;
 
            uint finalDate = 0;
            
            for(uint iii = 0; iii < strArr.length; iii++){
                string memory preConditionName = strArr[iii];
 
                for(uint j = 0;j < preConditionWorkings.length; j++){
                    if (isEqual(preConditionWorkings[j].workingType, preConditionName)){
 
                       Dataset.NodeData storage nodeData2 = preConditionWorkings[j];
                       if (isEqual(preConditionWorkings[j].workingType, workingType)){
                            nodeData2.delayDays = nodeData2.delayDays + delayDays;
                       }
                        
                        uint tStamp = addDays(nodeData2.startDate,
                                nodeData2.delayDays + nodeData2.workingDays);
 
                        if (tStamp > finalDate){
                            finalDate = tStamp;
 
                            if (tStamp > nodeData.startDate)
                                nodeData.startDate = tStamp;
                        }
 
                        //return;
                    }
                }
            }
        }
    }
 
 
    
    function setPreConditionDelayDays2(string memory workingType, uint delayDays) public {
        if (isEqual(workingType, ""))
            return;
 
        for(uint j = 0;j < preConditionWorkings.length; j++){
            if (isEqual(preConditionWorkings[j].workingType, workingType)){
 
                Dataset.NodeData storage nodeData = preConditionWorkings[j];
                nodeData.delayDays = nodeData.delayDays + delayDays;
 
                return;
            }
        }
    }
 
 
     
    function setLinkedListPreCondition(string memory hostWorkingName, string memory preConditionName,
        uint startY, uint startM, uint startD, uint workingDays) public returns(bool){
        
        uint256 listLength = getListLength();
        Dataset.NodeData[] memory listData = new Dataset.NodeData[](listLength + 1);
        for(uint256 i=1;i <= listLength;i++) {
            Dataset.NodeData storage nodeData = singlyLinkedList.getNodeData(i);
            if (isEqual(nodeData.workingType, hostWorkingName)){
                if (isEqual(nodeData.preConditionWorking, "")){
                    nodeData.preConditionWorking = preConditionName;
                }
                else{
                    string memory newStr = "&".toSlice().concat(preConditionName.toSlice());
                    nodeData.preConditionWorking = nodeData.preConditionWorking.toSlice().concat(newStr.toSlice());
                }
                //nodeData.preConditionWorking = preConditionName;
 
                addItem(preConditionName, startY, startM, startD, workingDays);
 
                return true;
            }
        }
        
        return false;
    }
 
 
     function split(string memory str1, string memory splitter) private view returns (string[] memory) {
         strings.slice memory s = str1.toSlice();
            strings.slice memory delim = splitter.toSlice();
            string[] memory parts = new string[](s.count(delim) + 1);
            
            for(uint i = 0; i < parts.length; i++) {
                parts[i] = s.split(delim).toString();
            }
 
        return parts;
    }
 
 
    function getStartDate(string memory workingType) public view returns(uint year, uint month, uint day){
        uint256 listLength = getListLength();
        Dataset.NodeData[] memory listData = new Dataset.NodeData[](listLength + 1);
        for(uint256 i=1;i <= listLength;i++) {
            Dataset.NodeData memory nodeData = singlyLinkedList.getNodeData(i);
            if (isEqual(nodeData.workingType, workingType)){
                // uint newTimestamp = addDays(nodeData.startDate, nodeData.delayDays + nodeData.workingDays);
                // return timestampToDate(newTimestamp);
                return timestampToDate(nodeData.startDate);
            }
        }
    }
 
    function getFinishDate(string memory workingType) public view returns(uint year, uint month, uint day){
        uint256 listLength = getListLength();
        Dataset.NodeData[] memory listData = new Dataset.NodeData[](listLength + 1);
        for(uint256 i=1;i <= listLength;i++) {
            Dataset.NodeData memory nodeData = singlyLinkedList.getNodeData(i);
            if (isEqual(nodeData.workingType, workingType)){
                uint newTimestamp = addDays(nodeData.startDate, nodeData.delayDays + nodeData.workingDays);
                return timestampToDate(newTimestamp);
            }
        }
    }
}