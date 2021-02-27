pragma solidity ^0.4.21;


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract linew {
    address [] public members; //評価を行う教育従事者のリスト（サービスのユーザーリスト）

    struct Archive{
        string name;
        string url;//指導記録のURL
        uint score;
        address owner;
        uint scorecount;
        bool drop;
    }

    Archive[] public archives;
    mapping(uint => address) archiveToOwner;

    struct Score{
        uint archiveId;
        address scoreOwner;
        uint score;
    }

    Score[] public scores;


    mapping(uint => address) scoreToOwner;
    mapping (address => uint) ownerArchiveCount;

    mapping (address => uint) public balanceOfNEW;//NEWトークンを定義




    //NEWトークンのAmountを確認する関数
    function checkBalanceOfNEW (address _address) public view returns (uint){
        return balanceOfNEW[_address];
    }

    //NEWトークンの付与
    function dropNEW (address _to, uint _amount) private {
        balanceOfNEW[_to] += _amount;
    }

    //NEWトークンの送金
    function sendNEW (address _to , uint _amount) public{
        if (_amount <= balanceOfNEW[msg.sender]){
            balanceOfNEW[msg.sender] -= _amount;
            balanceOfNEW[_to] += _amount;
        }
    }

    function deployArchive (string _name, string _url) public returns(uint) {
        uint id = archives.push(Archive(_name, _url ,0,msg.sender,0,false)) - 1;
        archiveToOwner[id] = msg.sender;
        return id;
    }



    function evaluateArchive (uint _id, uint256 _score) public returns (uint){
        require(_score <= 100 && _score >= 0);
        uint id = scores.push(Score(_id,msg.sender,_score)) - 1;//スコア証明書を登録
        scoreToOwner[id] = msg.sender; //score証明書IDと評価者を紐付ける。
        if (archives[_id].scorecount ==0){
            archives[_id].score = _score;
        }else{
            archives[_id].score = (archives[_id].score+_score)/2; //平均値を常にとる
        }
        archives[_id].scorecount++;
        //指導記録の提出者にNEWトークンを付与。（スコア分、X人以上が評価をし終えたら）
        if (archives[_id].scorecount == 3){
            dropNEW(archives[_id].owner,archives[_id].score);
        }

        return id; //scoreID
    }

    function receiveNEW(uint _scoreId)public returns (bool){
        bool result = false;
        if (archives[scores[_scoreId].archiveId].scorecount >= 3){
            if (scores[_scoreId].scoreOwner == msg.sender){
                uint gap = archives[scores[_scoreId].archiveId].score - scores[_scoreId].score;

                    if (gap*gap <= 25 && gap*gap >= 0){
                       dropNEW(msg.sender,25-gap*gap);
                       result = true;
                    }
            }
        }
        return result;
    }

    function getNameFromArchive (uint _id) public view returns (string){
        return archives[_id].name;
    }

    function getScoreFromArchive (uint _id) public view returns (uint){
        return archives[_id].score;
    }

    function getUrlFromArchive (uint _id) public view returns (string){
         return archives[_id].url;
    }
    function getOwnerFromArchive (uint _id) public view returns (address){
         return archives[_id].owner;
    }
    function getDropFromArchive (uint _id) public view returns (bool){
        return archives[_id].drop;
    }
    function getScorecountFromArchive (uint _id) public view returns (uint){
        return archives[_id].scorecount;
    }

    function getArchiveIdFromScore (uint _id) public view returns (uint){
         return scores[_id].archiveId;
    }
    function getScoreOwnerFromScore (uint _id) public view returns (address){
         return scores[_id].scoreOwner;
    }
    function getScoreFromScore (uint _id) public view returns (uint){
         return scores[_id].score;
    }

}
