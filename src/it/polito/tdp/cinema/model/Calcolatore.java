package it.polito.tdp.cinema.model;

public class Calcolatore {

    // accordo distributore-esercente
    private static final double SLIDING_1 = 0.95;
    private static final double SLIDING_2 = 0.90;
    private static final double SLIDING_3 = 0.85;
    private static final double SLIDING_4 = 0.50;
    private static final double BIDDING = 0.95;

    // accordo produttore-distributore
    private static final double LEASING_PERCENTUALE_BUDGET = 1.25;
    private static final double PROFIT_QUOTA_PRODUTTORE = 0.80;

    public static double quotaDistributore(Film f, AccordoEsercente accordo) {
        if (accordo == AccordoEsercente.SLIDING_SCALE) {
            return SLIDING_1 * f.getSett1() + SLIDING_2 * f.getSett2()
                 + SLIDING_3 * f.getSett3() + SLIDING_4 * f.getSett4();
        }
        return BIDDING * f.getBoxOffice();
    }

    public static Guadagno calcola(Film f, AccordoProduttore ap, AccordoEsercente ae) {
        double quota = quotaDistributore(f, ae);
        double utileProd;
        double guadDist;
        if (ap == AccordoProduttore.LEASING) {
            double pagamento = LEASING_PERCENTUALE_BUDGET * f.getBudget();
            utileProd = pagamento - f.getBudget();
            guadDist = quota - pagamento;
        } else {
            double allProduttore = PROFIT_QUOTA_PRODUTTORE * quota;
            utileProd = allProduttore - f.getBudget();
            guadDist = quota - allProduttore;
        }
        return new Guadagno(quota, utileProd, guadDist);
    }

    public static double utilePortafoglio(Film f) {
        return calcola(f, AccordoProduttore.PROFIT_SHARING, AccordoEsercente.SLIDING_SCALE).getUtileProduttore();
    }

    public static long spettatoriStimati(Film f, double prezzoMedio) {
        return Math.round(f.getBoxOffice() / prezzoMedio);
    }
}
