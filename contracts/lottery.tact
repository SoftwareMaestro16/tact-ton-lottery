import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";

message Withdraw {
    
}

contract Lottery with Deployable, OwnableTransferable, Stoppable, Resumable {
    owner: Address;
    stopped: Bool;
    bid: Int as uint128;
    minPrize: Int as uint128;
    maxPrize: Int as uint128;

    const MinTonForStorage: Int = ton("0.02");

    init(bid: Int, minPrize: Int, maxPrize: Int) {
        self.owner = sender();
        self.stopped = false;
        self.bid = bid;
        self.minPrize = minPrize;
        self.maxPrize = maxPrize;
    }

    receive() {
        // accept tons
    }

    receive("stop") {
        self.requireOwner();
        self.stopped = true;
    }

    receive("resume") {
        self.requireOwner();
        self.stopped = false;
    }

    receive("bid") {
        self.requireNotStopped();

        if (context().value == self.bid) {
            let seed: Int = getSeed();  
            setSeed(seed);               
            let prize: Int = random(self.minPrize, self.maxPrize); 

            if (myBalance() < prize) {
                send(SendParameters{
                to: sender(), 
                value: 0, 
                mode: SendRemainingValue + SendIgnoreErrors, 
                body: "insufficient funds".asComment()
            });
            } else {
                send(SendParameters{
                to: sender(),
                value: prize,
                mode: SendIgnoreErrors,
                body: "🌟".asComment()
            });
            }   
        } else {
            let str1: String = "bid must be ";
            let str2: String = self.bid.toCoinsString();
            let str3: String = " ton";
            let sb: StringBuilder = beginString();
            sb.append(str1);
            sb.append(str2);
            sb.append(str3);
            let str4 = sb.toString();

            send(SendParameters{
                to: sender(), 
                value: 0, 
                mode: SendRemainingValue + SendIgnoreErrors, 
                body: str4.asComment()
            });
        }
        
    }

    receive(msg: Withdraw) {
        self.requireOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: myBalance() - context().value - self.MinTonForStorage,
            mode: SendRemainingValue + SendIgnoreErrors
        });
    }

    get fun bid(): Int {
        return self.bid;
    }
    
}
