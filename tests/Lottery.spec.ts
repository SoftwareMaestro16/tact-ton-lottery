import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Lottery } from '../wrappers/Lottery';
import '@ton/test-utils';

describe('Lottery', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let lottery: SandboxContract<Lottery>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        lottery = blockchain.openContract(await Lottery.fromInit(
            toNano("0.6"),
            toNano("0.1"),
            toNano("1.25")
        ));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await lottery.send(
            deployer.getSender(),
            {
                value: toNano('2'),
            },
            {
                $$type: 'Deploy',
                queryId: 1n
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: lottery.address,
            deploy: true,
            success: true,
        });
    });

    it('should return correct message when bid is incorrect', async () => {
        // const user = await blockchain.treasury('user');
        // const bidResult = await lottery.send(
        //     user.getSender(),
        //     {
        //         value: toNano('0.6'), 
        //     },
        //     'bid'
        // );

        const requiredBid = await lottery.getBid();
        console.log(requiredBid);

        expect(toNano('0.61')).toEqual(requiredBid);
    });
});
